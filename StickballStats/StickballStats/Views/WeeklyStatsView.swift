//
//  WeeklyStatsView.swift
//  Dong Country Ledger 5000
//
//  Weekly stats entry and viewing
//

import SwiftUI

struct WeeklyStatsView: View {
    @EnvironmentObject var statsService: StatsService
    @State private var showingPlayerSelection = false
    @State private var showingBatchEntry = false
    @State private var selectedPlayer: Player?

    // Players who have stats for current week (i.e., were selected to play)
    var playersThisWeek: [Player] {
        let weekStats = statsService.getWeeklyStatsForWeek(statsService.currentWeek)
        let playerIds = Set(weekStats.map { $0.playerId })
        return statsService.players.filter { playerIds.contains($0.id ?? "") }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                TronGridBackground()

                VStack(spacing: 0) {
                    // Header with week navigation
                    WeekNavigationHeader()
                        .environmentObject(statsService)

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

                            Spacer()
                        }
                    } else {
                        // Show players with their stats
                        ScrollView {
                            LazyVStack(spacing: 6) {
                                ForEach(playersThisWeek) { player in
                                    if let stats = currentWeekStats(for: player) {
                                        WeeklyStatRow(
                                            player: player,
                                            stats: stats,
                                            onTap: { selectedPlayer = player }
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
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
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                // Short name (max 4 chars)
                Text(player.name.shortName)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(TronColors.cyan)
                    .frame(width: 50, alignment: .leading)

                // Stats in a row
                HStack(spacing: 4) {
                    CompactStatBadge(value: stats.dongs, label: "D", color: TronColors.cyan)
                    CompactStatBadge(value: stats.drops, label: "R", color: TronColors.orange)
                    CompactStatBadge(value: stats.doublePlays, label: "DP", color: TronColors.magenta)
                    CompactStatBadge(value: stats.salamies, label: "S", color: TronColors.green)
                    CompactStatBadge(value: stats.wins, label: "W", color: TronColors.yellow)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundColor(TronColors.dimText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(TronColors.cardBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(TronColors.gridLine.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Compact Stat Badge
struct CompactStatBadge: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 1) {
            Text("\(value)")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(value > 0 ? color : TronColors.dimText)

            Text(label)
                .font(.system(size: 7, weight: .medium, design: .monospaced))
                .foregroundColor(color.opacity(0.6))
        }
        .frame(width: 32)
    }
}

// MARK: - Week Navigation Header
struct WeekNavigationHeader: View {
    @EnvironmentObject var statsService: StatsService

    var currentField: GameField? {
        statsService.getFieldForWeek(statsService.currentWeekNumber)
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

            // Field display (read-only)
            if let field = currentField {
                HStack(spacing: 6) {
                    Image(systemName: fieldIcon)
                        .font(.system(size: 12))
                    Text(field.rawValue.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                }
                .foregroundColor(TronColors.green)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(TronColors.surfaceBackground)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(TronColors.green.opacity(0.5), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(TronColors.cardBackground.opacity(0.8))
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
}
