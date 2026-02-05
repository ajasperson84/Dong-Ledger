//
//  WeeklyStatsView.swift
//  StickballStats
//
//  Weekly stats entry and viewing
//

import SwiftUI

struct WeeklyStatsView: View {
    @EnvironmentObject var statsService: StatsService
    @State private var showingBatchEntry = false
    @State private var selectedPlayer: Player?

    var body: some View {
        NavigationStack {
            ZStack {
                TronGridBackground()

                VStack(spacing: 0) {
                    // Header with week navigation
                    WeekNavigationHeader()
                        .environmentObject(statsService)

                    // Stats list
                    if statsService.players.isEmpty {
                        EmptyStateView(
                            icon: "person.badge.plus",
                            title: "NO PLAYERS",
                            message: "Add players in the Players tab to start tracking stats"
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(statsService.players) { player in
                                    let stats = currentWeekStats(for: player)
                                    PlayerRow(
                                        player: player,
                                        stats: stats,
                                        rank: nil,
                                        onTap: {
                                            selectedPlayer = player
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
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
                    Button(action: { showingBatchEntry = true }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(TronColors.cyan)
                    }
                }
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

// MARK: - Week Navigation Header
struct WeekNavigationHeader: View {
    @EnvironmentObject var statsService: StatsService

    var body: some View {
        HStack {
            Button(action: { statsService.previousWeek() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(TronColors.cyan)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("WEEK \(statsService.currentWeek)")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(TronColors.cyan)
                    .neonGlow(color: TronColors.cyan, radius: 8)

                Text("\(statsService.currentYear)")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(TronColors.secondaryText)
            }

            Spacer()

            Button(action: { statsService.nextWeek() }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(TronColors.cyan)
                    .frame(width: 44, height: 44)
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
