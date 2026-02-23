//
//  WeeklyStatsView.swift
//  Dong Country Ledger 5000
//
//  Weekly stats entry and viewing
//

import SwiftUI

struct WeeklyStatsView: View {
    @EnvironmentObject var statsService: StatsService
    @EnvironmentObject var adminService: AdminService
    @State private var showingPlayerSelection = false
    @State private var showingBatchEntry = false
    @State private var selectedPlayer: Player?

    // Players who have stats for current week (i.e., were selected to play)
    var playersThisWeek: [Player] {
        let weekStats = statsService.getWeeklyStatsForWeek(statsService.currentWeek)
        let playerIds = Set(weekStats.map { $0.playerId })
        return statsService.players.filter { playerIds.contains($0.id ?? "") }
    }

    // Weekly totals
    var weeklyTotals: (dongs: Int, drops: Int, doublePlays: Int, salamies: Int) {
        let weekStats = statsService.getWeeklyStatsForWeek(statsService.currentWeek)
        let totalDongs = weekStats.reduce(0) { $0 + $1.dongs }
        let totalDrops = weekStats.reduce(0) { $0 + $1.drops }
        let totalDPs = weekStats.reduce(0) { $0 + $1.doublePlays }
        let totalSalamies = weekStats.reduce(0) { $0 + $1.salamies }
        return (totalDongs, totalDrops, totalDPs, totalSalamies)
    }

    // Player of the Week calculation
    var playerOfTheWeek: (player: Player, score: Double, dongs: Int, doublePlays: Int, wins: Int, drops: Int)? {
        let weekStats = statsService.getWeeklyStatsForWeek(statsService.currentWeek)
        guard !weekStats.isEmpty else { return nil }

        var bestPlayer: Player?
        var bestScore: Double = -Double.infinity
        var bestStats: WeeklyStats?

        for stats in weekStats {
            let score = AchievementsCalculator.calculateWeeklyScore(
                dongs: stats.dongs,
                doublePlays: stats.doublePlays,
                wins: stats.wins,
                drops: stats.drops
            )
            if score > bestScore {
                bestScore = score
                bestStats = stats
                bestPlayer = statsService.players.first { $0.id == stats.playerId }
            }
        }

        guard let player = bestPlayer, let stats = bestStats, bestScore > 0 else { return nil }
        return (player, bestScore, stats.dongs, stats.doublePlays, stats.wins, stats.drops)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                TronGridBackground()

                VStack(spacing: 0) {
                    // Header with week navigation
                    WeekNavigationHeader()
                        .environmentObject(statsService)
                        .environmentObject(adminService)

                    // Content based on state
                    if statsService.players.isEmpty {
                        EmptyStateView(
                            icon: "person.badge.plus",
                            title: "NO PLAYERS",
                            message: "Add players in the Players tab to start tracking stats"
                        )
                    } else if playersThisWeek.isEmpty {
                        // No players selected for this week yet
                        VStack(spacing: 20) {
                            Spacer()

                            Image(systemName: "person.3.sequence")
                                .font(.system(size: 56))
                                .foregroundColor(TronColors.cyan.opacity(0.5))

                            Text("NO PLAYERS ADDED")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(TronColors.secondaryText)

                            Text("Select who played this week")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(TronColors.dimText)

                            if adminService.isAdminMode {
                                Button(action: { showingPlayerSelection = true }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("ADD PLAYERS")
                                    }
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(TronColors.darkBackground)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                                    .background(TronColors.green)
                                    .cornerRadius(10)
                                    .neonGlow(color: TronColors.green, radius: 8)
                                }
                                .padding(.top, 8)
                            } else {
                                Text("Admin mode required to add players")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(TronColors.dimText)
                                    .padding(.top, 8)
                            }

                            Spacer()
                        }
                    } else {
                        // Show players with their stats
                        ScrollView {
                            VStack(spacing: 12) {
                                // Weekly totals summary bar
                                WeeklyTotalsSummary(
                                    dongs: weeklyTotals.dongs,
                                    drops: weeklyTotals.drops,
                                    doublePlays: weeklyTotals.doublePlays,
                                    salamies: weeklyTotals.salamies
                                )
                                .padding(.horizontal, 12)

                                // Player of the Week
                                if let potw = playerOfTheWeek {
                                    PlayerOfTheWeekCard(
                                        playerName: potw.player.name,
                                        dongs: potw.dongs,
                                        doublePlays: potw.doublePlays,
                                        wins: potw.wins,
                                        drops: potw.drops
                                    )
                                    .padding(.horizontal, 12)
                                }

                                LazyVStack(spacing: 6) {
                                    ForEach(playersThisWeek) { player in
                                        if let stats = currentWeekStats(for: player) {
                                            WeeklyStatRow(
                                                player: player,
                                                stats: stats,
                                                isAdminMode: adminService.isAdminMode,
                                                onTap: {
                                                    if adminService.isAdminMode {
                                                        selectedPlayer = player
                                                    }
                                                }
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 12)
                            }
                            .padding(.vertical, 12)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("WEEKLY STATS")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.cyan)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if adminService.isAdminMode {
                        HStack(spacing: 12) {
                            // Add/edit players for week
                            Button(action: { showingPlayerSelection = true }) {
                                Image(systemName: "person.badge.plus")
                                    .foregroundColor(TronColors.green)
                            }

                            // Batch edit stats
                            if !playersThisWeek.isEmpty {
                                Button(action: { showingBatchEntry = true }) {
                                    Image(systemName: "square.and.pencil")
                                        .foregroundColor(TronColors.cyan)
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingPlayerSelection) {
                WeeklyPlayerSelectionView()
                    .environmentObject(statsService)
            }
            .sheet(item: $selectedPlayer) { player in
                PlayerStatsEntryView(player: player)
                    .environmentObject(statsService)
            }
            .sheet(isPresented: $showingBatchEntry) {
                BatchStatsEntryView()
                    .environmentObject(statsService)
            }
        }
    }

    private func currentWeekStats(for player: Player) -> WeeklyStats? {
        guard let playerId = player.id else { return nil }
        return statsService.weeklyStats.first {
            $0.playerId == playerId &&
            $0.weekNumber == statsService.currentWeek &&
            $0.year == statsService.currentYear
        }
    }
}

// MARK: - Weekly Stat Row (Compact with short names)
struct WeeklyStatRow: View {
    let player: Player
    let stats: WeeklyStats
    var isAdminMode: Bool = true
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                // Player name
                Text(player.name.shortName)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(TronColors.cyan)
                    .frame(width: 64, alignment: .leading)
                    .lineLimit(1)

                // Stats in a row - spread across the screen
                HStack(spacing: 0) {
                    CompactStatBadge(value: stats.dongs, label: "D", color: TronColors.cyan)
                    CompactStatBadge(value: stats.drops, label: "R", color: TronColors.orange)
                    CompactStatBadge(value: stats.doublePlays, label: "DP", color: TronColors.magenta)
                    CompactStatBadge(value: stats.salamies, label: "S", color: TronColors.green)
                    CompactStatBadge(value: stats.wins, label: "W", color: TronColors.yellow)
                }

                // Only show edit chevron in admin mode
                if isAdminMode {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                        .foregroundColor(TronColors.dimText)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(TronColors.cardBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(TronColors.gridLine.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isAdminMode)
    }
}

// MARK: - Compact Stat Badge
struct CompactStatBadge: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(value > 0 ? color : TronColors.dimText)

            Text(label)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(color.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Week Navigation Header
struct WeekNavigationHeader: View {
    @EnvironmentObject var statsService: StatsService
    @EnvironmentObject var adminService: AdminService
    @State private var showingFieldPicker = false

    var body: some View {
        VStack(spacing: 8) {
            // Main navigation row
            HStack {
                Button(action: { statsService.previousWeek() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(statsService.canGoPrevious() ? TronColors.cyan : TronColors.dimText)
                        .frame(width: 44, height: 44)
                }
                .disabled(!statsService.canGoPrevious())

                Spacer()

                VStack(spacing: 4) {
                    // Special event name or Week number
                    if let gameWeek = statsService.currentGameWeek {
                        if let event = gameWeek.specialEvent {
                            Text(event.rawValue.uppercased())
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(TronColors.magenta)
                                .neonGlow(color: TronColors.magenta, radius: 5)
                        }

                        Text("WEEK \(statsService.currentWeekNumber)")
                            .font(.system(size: gameWeek.specialEvent != nil ? 16 : 24, weight: .bold, design: .monospaced))
                            .foregroundColor(TronColors.cyan)
                            .neonGlow(color: TronColors.cyan, radius: gameWeek.specialEvent != nil ? 4 : 8)

                        // Date
                        Text(gameWeek.formattedDate.uppercased())
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(TronColors.secondaryText)
                    } else {
                        Text("WEEK \(statsService.currentWeekNumber)")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(TronColors.cyan)
                            .neonGlow(color: TronColors.cyan, radius: 8)
                    }
                }

                Spacer()

                Button(action: { statsService.nextWeek() }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(statsService.canGoNext() ? TronColors.cyan : TronColors.dimText)
                        .frame(width: 44, height: 44)
                }
                .disabled(!statsService.canGoNext())
            }

            // Field selector button (read-only for non-admins)
            FieldSelectorButton(
                weekNumber: statsService.currentWeekNumber,
                isAdminMode: adminService.isAdminMode,
                onTap: { showingFieldPicker = true }
            )
            .environmentObject(statsService)
            .sheet(isPresented: $showingFieldPicker) {
                FieldPickerSheet(weekNumber: statsService.currentWeekNumber)
                    .environmentObject(statsService)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(TronColors.cardBackground.opacity(0.8))
    }
}

// MARK: - Field Selector Button
struct FieldSelectorButton: View {
    @EnvironmentObject var statsService: StatsService
    let weekNumber: Int
    var isAdminMode: Bool = true
    let onTap: () -> Void

    var currentField: GameField? {
        statsService.gameWeekInfos[weekNumber]?.gameField
    }

    var fieldIcon: String {
        guard let field = currentField else { return "mappin.circle" }
        switch field {
        case .theDam: return "water.waves"
        case .theSpreadingGrounds: return "leaf.fill"
        case .theAirfield: return "airplane"
        }
    }

    var body: some View {
        // Force dependency on lastFieldUpdate to ensure refresh
        let _ = statsService.lastFieldUpdate

        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: fieldIcon)
                    .font(.system(size: 12))
                if let field = currentField {
                    Text(field.rawValue.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                } else {
                    Text("NO FIELD SET")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                }
                if isAdminMode {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9))
                }
            }
            .foregroundColor(currentField != nil ? TronColors.green : TronColors.dimText)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(TronColors.surfaceBackground)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(currentField != nil ? TronColors.green.opacity(0.5) : TronColors.gridLine.opacity(0.3), lineWidth: 1)
            )
        }
        .disabled(!isAdminMode)
    }
}

// MARK: - Field Picker Sheet
struct FieldPickerSheet: View {
    @EnvironmentObject var statsService: StatsService
    @Environment(\.dismiss) var dismiss
    let weekNumber: Int

    var body: some View {
        NavigationStack {
            ZStack {
                TronGridBackground()

                VStack(spacing: 20) {
                    Text("SELECT FIELD")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.cyan)
                        .neonGlow(color: TronColors.cyan, radius: 5)
                        .padding(.top, 20)

                    VStack(spacing: 12) {
                        ForEach(GameField.allCases, id: \.self) { field in
                            FieldOptionRow(
                                field: field,
                                isSelected: statsService.getFieldForWeek(weekNumber) == field,
                                onSelect: {
                                    Task {
                                        try? await statsService.updateGameWeekField(weekNumber: weekNumber, field: field)
                                        dismiss()
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(TronColors.orange)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Field Option Row
struct FieldOptionRow: View {
    let field: GameField
    let isSelected: Bool
    let onSelect: () -> Void

    var fieldIcon: String {
        switch field {
        case .theDam: return "water.waves"
        case .theSpreadingGrounds: return "leaf.fill"
        case .theAirfield: return "airplane"
        }
    }

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: fieldIcon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? TronColors.green : TronColors.secondaryText)
                    .frame(width: 32)

                Text(field.rawValue.uppercased())
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(isSelected ? TronColors.green : TronColors.primaryText)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(TronColors.green)
                        .neonGlow(color: TronColors.green, radius: 5)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isSelected ? TronColors.green.opacity(0.1) : TronColors.cardBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? TronColors.green.opacity(0.5) : TronColors.gridLine.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Player of the Week Card
struct PlayerOfTheWeekCard: View {
    let playerName: String
    let dongs: Int
    let doublePlays: Int
    let wins: Int
    let drops: Int

    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(TronColors.yellow)
                Text("PLAYER OF THE WEEK")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(TronColors.yellow)
                Image(systemName: "star.fill")
                    .foregroundColor(TronColors.yellow)
            }

            // Player name
            Text(playerName.uppercased())
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(TronColors.primaryText)
                .neonGlow(color: TronColors.yellow, radius: 5)

            // Stats breakdown
            HStack(spacing: 16) {
                MiniStatBadge(value: dongs, label: "D", color: TronColors.cyan)
                MiniStatBadge(value: doublePlays, label: "DP", color: TronColors.magenta)
                MiniStatBadge(value: wins, label: "W", color: TronColors.yellow)
                MiniStatBadge(value: drops, label: "DR", color: TronColors.orange, negative: true)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(TronColors.yellow.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(TronColors.yellow.opacity(0.5), lineWidth: 2)
        )
        .neonGlow(color: TronColors.yellow, radius: 5)
    }
}

// MARK: - Mini Stat Badge (for POTW)
struct MiniStatBadge: View {
    let value: Int
    let label: String
    let color: Color
    var negative: Bool = false

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(negative && value > 0 ? color : (value > 0 ? color : TronColors.dimText))

            Text(label)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(color.opacity(0.7))
        }
    }
}

// MARK: - Weekly Totals Summary
struct WeeklyTotalsSummary: View {
    let dongs: Int
    let drops: Int
    let doublePlays: Int
    let salamies: Int

    var body: some View {
        HStack(spacing: 0) {
            TotalStatCell(value: dongs, label: "DONGS", color: TronColors.cyan)
            Divider()
                .frame(height: 30)
                .background(TronColors.gridLine.opacity(0.3))
            TotalStatCell(value: drops, label: "DROPS", color: TronColors.orange)
            Divider()
                .frame(height: 30)
                .background(TronColors.gridLine.opacity(0.3))
            TotalStatCell(value: doublePlays, label: "DBL PLY", color: TronColors.magenta)
            Divider()
                .frame(height: 30)
                .background(TronColors.gridLine.opacity(0.3))
            TotalStatCell(value: salamies, label: "SALAMIES", color: TronColors.green)
        }
        .padding(.vertical, 10)
        .background(TronColors.cardBackground)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(TronColors.cyan.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Total Stat Cell
struct TotalStatCell: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .neonGlow(color: color, radius: 4)

            Text(label)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(color.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(TronColors.cyan.opacity(0.5))

            Text(title)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(TronColors.secondaryText)

            Text(message)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(TronColors.dimText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WeeklyStatsView()
        .environmentObject(StatsService())
        .environmentObject(AdminService.shared)
}
