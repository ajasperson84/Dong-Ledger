//
//  StatsService.swift
//  StickballStats
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

    @Published var players: [Player] = []
    @Published var weeklyStats: [WeeklyStats] = []
    @Published var yearlyStats: [YearlyStats] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var currentYear: Int
    @Published var currentWeek: Int

    init() {
        // Get current week and year
        let calendar = Calendar.current
        let now = Date()
        self.currentYear = calendar.component(.year, from: now)
        self.currentWeek = calendar.component(.weekOfYear, from: now)

        print("🚀 StatsService initializing...")
        print("📅 Current week: \(currentWeek), year: \(currentYear)")
        setupListeners()
    }

    deinit {
        playersListener?.remove()
        statsListener?.remove()
    }

    // MARK: - Real-time Listeners

    private func setupListeners() {
        // Listen for player changes
        // Note: Using simple query to avoid requiring composite index
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

                    // Filter and sort in memory to avoid needing composite index
                    self?.players = documents.compactMap { doc in
                        try? doc.data(as: Player.self)
                    }
                    .filter { $0.isActive }
                    .sorted { $0.name.lowercased() < $1.name.lowercased() }

                    print("✅ Active players: \(self?.players.count ?? 0)")
                }
            }

        // Listen for stats changes for current year
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

                    // Filter by year in memory
                    let currentYear = self?.currentYear ?? Calendar.current.component(.year, from: Date())
                    self?.weeklyStats = documents.compactMap { doc in
                        try? doc.data(as: WeeklyStats.self)
                    }
                    .filter { $0.year == currentYear }
                    .sorted { ($0.weekNumber, $0.playerName) < ($1.weekNumber, $1.playerName) }

                    self?.calculateYearlyStats()
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
        // Soft delete - just mark as inactive
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

        // Check if stats already exist
        let query = db.collection("weeklyStats")
            .whereField("playerId", isEqualTo: playerId)
            .whereField("weekNumber", isEqualTo: week)
            .whereField("year", isEqualTo: year)

        let snapshot = try await query.getDocuments()

        if let existingDoc = snapshot.documents.first,
           let existingStats = try? existingDoc.data(as: WeeklyStats.self) {
            return existingStats
        }

        // Create new stats entry
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

    // MARK: - Stats Calculations

    func calculateYearlyStats() {
        var statsDict: [String: YearlyStats] = [:]

        for weekly in weeklyStats where weekly.year == currentYear {
            if var yearly = statsDict[weekly.playerId] {
                yearly.addWeeklyStats(weekly)
                statsDict[weekly.playerId] = yearly
            } else {
                var newYearly = YearlyStats(playerId: weekly.playerId, playerName: weekly.playerName, year: currentYear)
                newYearly.addWeeklyStats(weekly)
                statsDict[weekly.playerId] = newYearly
            }
        }

        yearlyStats = Array(statsDict.values).sorted { $0.totalPoints > $1.totalPoints }
    }

    func getWeeklyStatsForWeek(_ week: Int) -> [WeeklyStats] {
        return weeklyStats.filter { $0.weekNumber == week && $0.year == currentYear }
    }

    func getStatsForPlayer(_ playerId: String) -> [WeeklyStats] {
        return weeklyStats.filter { $0.playerId == playerId }.sorted { $0.weekNumber < $1.weekNumber }
    }

    // MARK: - Week Navigation

    func previousWeek() {
        if currentWeek > 1 {
            currentWeek -= 1
        } else {
            currentWeek = 52
            currentYear -= 1
            refreshStatsListener()
        }
    }

    func nextWeek() {
        let calendar = Calendar.current
        let maxWeek = calendar.component(.weekOfYear, from: Date())
        let thisYear = calendar.component(.year, from: Date())

        if currentYear < thisYear || currentWeek < maxWeek {
            if currentWeek < 52 {
                currentWeek += 1
            } else {
                currentWeek = 1
                currentYear += 1
                refreshStatsListener()
            }
        }
    }

    private func refreshStatsListener() {
        statsListener?.remove()

        statsListener = db.collection("weeklyStats")
            .whereField("year", isEqualTo: currentYear)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    if let error = error {
                        self?.errorMessage = "Failed to load stats: \(error.localizedDescription)"
                        return
                    }

                    guard let documents = snapshot?.documents else { return }

                    self?.weeklyStats = documents.compactMap { doc in
                        try? doc.data(as: WeeklyStats.self)
                    }.sorted { ($0.weekNumber, $0.playerName) < ($1.weekNumber, $1.playerName) }

                    self?.calculateYearlyStats()
                }
            }
    }
}
