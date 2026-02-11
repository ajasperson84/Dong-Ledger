//
//  StatsService.swift
//  Dong Country Ledger 5000
//
//  Firebase Firestore service for real-time cloud sync
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class StatsService: ObservableObject {
    private let db = Firestore.firestore()
    private var playersListener: ListenerRegistration?
    private var statsListener: ListenerRegistration?
    private var gameWeekInfoListener: ListenerRegistration?

    @Published var players: [Player] = []
    @Published var weeklyStats: [WeeklyStats] = []
    @Published var yearlyStats: [YearlyStats] = []
    @Published var gameWeekInfos: [Int: GameWeekInfo] = [:]  // weekNumber -> info
    @Published var lastFieldUpdate: Date = Date()  // Triggers view refresh when field changes
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Season schedule
    let schedule = SeasonSchedule.shared

    // Current week index (0-based) in the season schedule
    @Published var currentWeekIndex: Int

    // Computed properties for current week
    var currentGameWeek: GameWeek? {
        schedule.gameWeek(atIndex: currentWeekIndex)
    }

    var currentWeekNumber: Int {
        currentGameWeek?.weekNumber ?? 1
    }

    // Alias for backward compatibility
    var currentWeek: Int {
        currentWeekNumber
    }

    var currentYear: Int {
        currentGameWeek?.year ?? 2026
    }

    init() {
        // Start at the most recent game that has been played
        self.currentWeekIndex = SeasonSchedule.shared.currentWeekIndex()

        print("🚀 StatsService initializing...")
        print("📅 Current week index: \(currentWeekIndex), week number: \(currentWeekNumber)")
        if let gameWeek = currentGameWeek {
            print("📅 Game date: \(gameWeek.formattedDate)")
            if let event = gameWeek.specialEvent {
                print("🎉 Special event: \(event.rawValue)")
            }
        }
        setupListeners()
    }

    deinit {
        playersListener?.remove()
        statsListener?.remove()
        gameWeekInfoListener?.remove()
    }

    // MARK: - Real-time Listeners

    private func setupListeners() {
        // Listen for player changes
        playersListener = db.collection("players")
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    if let error = error {
                        print("❌ Firestore players error: \(error.localizedDescription)")
                        self?.errorMessage = "Failed to load players: \(error.localizedDescription)"
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        print("⚠️ No player documents found")
                        return
                    }

                    print("✅ Loaded \(documents.count) player documents")

                    self?.players = documents.compactMap { doc in
                        try? doc.data(as: Player.self)
                    }
                    .filter { $0.isActive }
                    .sorted { $0.name.lowercased() < $1.name.lowercased() }

                    print("✅ Active players: \(self?.players.count ?? 0)")
                }
            }

        // Listen for all stats (we filter by season in memory)
        statsListener = db.collection("weeklyStats")
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    if let error = error {
                        print("❌ Firestore stats error: \(error.localizedDescription)")
                        self?.errorMessage = "Failed to load stats: \(error.localizedDescription)"
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        print("⚠️ No stats documents found")
                        return
                    }

                    print("✅ Loaded \(documents.count) stats documents")

                    self?.weeklyStats = documents.compactMap { doc in
                        try? doc.data(as: WeeklyStats.self)
                    }
                    .sorted { ($0.weekNumber, $0.playerName) < ($1.weekNumber, $1.playerName) }

                    self?.calculateSeasonStats()
                }
            }

        // Listen for game week info (field selections)
        gameWeekInfoListener = db.collection("gameWeekInfo")
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    if let error = error {
                        print("❌ Firestore gameWeekInfo error: \(error.localizedDescription)")
                        return
                    }

                    guard let documents = snapshot?.documents else { return }

                    var infos: [Int: GameWeekInfo] = [:]
                    for doc in documents {
                        if let info = try? doc.data(as: GameWeekInfo.self) {
                            infos[info.weekNumber] = info
                        }
                    }
                    self?.gameWeekInfos = infos
                    print("✅ Loaded \(infos.count) game week infos")
                }
            }
    }

    // MARK: - Player Management

    func addPlayer(name: String, jerseyNumber: Int? = nil, teamName: String? = nil) async throws {
        let player = Player(name: name, jerseyNumber: jerseyNumber, teamName: teamName)
        print("📝 Adding player: \(name)")
        do {
            let docRef = try db.collection("players").addDocument(from: player)
            print("✅ Player added with ID: \(docRef.documentID)")
        } catch {
            print("❌ Failed to add player: \(error.localizedDescription)")
            throw error
        }
    }

    func updatePlayer(_ player: Player) async throws {
        guard let playerId = player.id else { return }
        var updatedPlayer = player
        updatedPlayer.updatedAt = Date()
        try db.collection("players").document(playerId).setData(from: updatedPlayer)
    }

    func deletePlayer(_ player: Player) async throws {
        guard let playerId = player.id else { return }
        try await db.collection("players").document(playerId).updateData([
            "isActive": false,
            "updatedAt": Date()
        ])
    }

    // MARK: - Stats Management

    func getOrCreateWeeklyStats(for player: Player, week: Int, year: Int) async throws -> WeeklyStats {
        guard let playerId = player.id else {
            throw NSError(domain: "StatsService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Player ID is nil"])
        }

        let query = db.collection("weeklyStats")
            .whereField("playerId", isEqualTo: playerId)
            .whereField("weekNumber", isEqualTo: week)
            .whereField("year", isEqualTo: year)

        let snapshot = try await query.getDocuments()

        if let existingDoc = snapshot.documents.first,
           let existingStats = try? existingDoc.data(as: WeeklyStats.self) {
            return existingStats
        }

        var newStats = WeeklyStats(playerId: playerId, playerName: player.name, weekNumber: week, year: year)
        let docRef = try db.collection("weeklyStats").addDocument(from: newStats)
        newStats.id = docRef.documentID
        return newStats
    }

    func updateWeeklyStats(_ stats: WeeklyStats) async throws {
        guard let statsId = stats.id else { return }
        var updatedStats = stats
        updatedStats.updatedAt = Date()
        try db.collection("weeklyStats").document(statsId).setData(from: updatedStats)
    }

    func batchUpdateStats(_ statsArray: [WeeklyStats]) async throws {
        let batch = db.batch()

        for stats in statsArray {
            guard let statsId = stats.id else { continue }
            var updatedStats = stats
            updatedStats.updatedAt = Date()
            let docRef = db.collection("weeklyStats").document(statsId)
            try batch.setData(from: updatedStats, forDocument: docRef)
        }

        try await batch.commit()
    }

    // MARK: - Game Week Info (Field Selection)

    func getOrCreateGameWeekInfo(for weekNumber: Int) async throws -> GameWeekInfo {
        if let existing = gameWeekInfos[weekNumber] {
            return existing
        }

        let query = db.collection("gameWeekInfo")
            .whereField("weekNumber", isEqualTo: weekNumber)

        let snapshot = try await query.getDocuments()

        if let existingDoc = snapshot.documents.first,
           let existingInfo = try? existingDoc.data(as: GameWeekInfo.self) {
            return existingInfo
        }

        var newInfo = GameWeekInfo(weekNumber: weekNumber)
        let docRef = try db.collection("gameWeekInfo").addDocument(from: newInfo)
        newInfo.id = docRef.documentID
        return newInfo
    }

    func updateGameWeekField(weekNumber: Int, field: GameField?) async throws {
        print("🔄 updateGameWeekField called for week \(weekNumber) with field: \(field?.rawValue ?? "nil")")

        var info = try await getOrCreateGameWeekInfo(for: weekNumber)
        print("📋 Got/created info with id: \(info.id ?? "nil")")

        info.setField(field)

        if let infoId = info.id {
            try db.collection("gameWeekInfo").document(infoId).setData(from: info)

            // Update local cache immediately so UI reflects the change
            gameWeekInfos[weekNumber] = info

            // Update timestamp to trigger view refresh
            lastFieldUpdate = Date()

            print("✅ Updated field for week \(weekNumber): \(field?.rawValue ?? "none")")
            print("📊 gameWeekInfos now has \(gameWeekInfos.count) entries")
            print("📊 Field for week \(weekNumber) is now: \(getFieldForWeek(weekNumber)?.rawValue ?? "nil")")
        } else {
            print("❌ No ID for gameWeekInfo, cannot save")
        }
    }

    func getFieldForWeek(_ weekNumber: Int) -> GameField? {
        let field = gameWeekInfos[weekNumber]?.gameField
        print("🔍 getFieldForWeek(\(weekNumber)) returning: \(field?.rawValue ?? "nil")")
        return field
    }

    // MARK: - Stats Calculations

    func calculateSeasonStats() {
        var statsDict: [String: YearlyStats] = [:]

        // Include all stats from the season (both 2025 and 2026 portions)
        // Apply alias mapping to merge duplicates (e.g., "Boogie" -> "Boogie Joe")
        for weekly in weeklyStats {
            // Check if this week is part of our season
            if schedule.gameWeek(forWeekNumber: weekly.weekNumber) != nil {
                let year = 2026 // Use consistent year for season stats
                // Apply alias mapping to get canonical player name
                let canonicalName = PlayerAliases.canonicalName(for: weekly.playerName)

                // Use canonical name as key to merge aliases
                if var yearly = statsDict[canonicalName] {
                    yearly.addWeeklyStats(weekly)
                    statsDict[canonicalName] = yearly
                } else {
                    var newYearly = YearlyStats(playerId: weekly.playerId, playerName: canonicalName, year: year)
                    newYearly.addWeeklyStats(weekly)
                    statsDict[canonicalName] = newYearly
                }
            }
        }

        yearlyStats = Array(statsDict.values).sorted { $0.totalDongs > $1.totalDongs }
    }

    func getWeeklyStatsForWeek(_ week: Int) -> [WeeklyStats] {
        return weeklyStats.filter { $0.weekNumber == week }
    }

    func getStatsForPlayer(_ playerId: String) -> [WeeklyStats] {
        return weeklyStats.filter { $0.playerId == playerId }.sorted { $0.weekNumber < $1.weekNumber }
    }

    // MARK: - Week Navigation

    func previousWeek() {
        if currentWeekIndex > 0 {
            currentWeekIndex -= 1
            print("⬅️ Moved to week \(currentWeekNumber)")
        }
    }

    func nextWeek() {
        let maxIndex = schedule.currentWeekIndex()
        if currentWeekIndex < maxIndex {
            currentWeekIndex += 1
            print("➡️ Moved to week \(currentWeekNumber)")
        } else {
            print("⚠️ Cannot advance past current date")
        }
    }

    func canGoNext() -> Bool {
        return currentWeekIndex < schedule.currentWeekIndex()
    }

    func canGoPrevious() -> Bool {
        return currentWeekIndex > 0
    }

    // Jump to specific week
    func goToWeek(index: Int) {
        let maxIndex = schedule.currentWeekIndex()
        if index >= 0 && index <= maxIndex {
            currentWeekIndex = index
        }
    }
}
