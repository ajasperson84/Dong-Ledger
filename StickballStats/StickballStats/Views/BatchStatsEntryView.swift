//
//  BatchStatsEntryView.swift
//  Dong Country Ledger 5000
//
//  Quick batch entry for players' weekly stats
//

import SwiftUI

struct BatchStatsEntryView: View {
    @EnvironmentObject var statsService: StatsService
    @Environment(\.dismiss) var dismiss

    @State private var playerStats: [String: WeeklyStats] = [:]
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var expandedPlayerId: String?

    // Only show players who were selected for this week
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
                    // Week header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("BATCH ENTRY")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(TronColors.secondaryText)

                            Text("WEEK \(statsService.currentWeek)")
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(TronColors.cyan)
                                .neonGlow(color: TronColors.cyan, radius: 5)
                        }

                        Spacer()

                        // Save all button
                        Button(action: saveAllStats) {
                            HStack(spacing: 6) {
                                if isSaving {
                                    ProgressView()
                                        .tint(TronColors.darkBackground)
                                        .scaleEffect(0.7)
                                } else {
                                    Image(systemName: "arrow.up.circle.fill")
                                    Text("SAVE ALL")
                                }
                            }
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(TronColors.darkBackground)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(TronColors.green)
                            .cornerRadius(8)
                            .neonGlow(color: TronColors.green, radius: 5)
                        }
                        .disabled(isSaving)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(TronColors.cardBackground)

                    if isLoading {
                        Spacer()
                        ProgressView()
                            .tint(TronColors.cyan)
                            .scaleEffect(1.5)
                        Spacer()
                    } else if playersThisWeek.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "person.3")
                                .font(.system(size: 40))
                                .foregroundColor(TronColors.dimText)
                            Text("NO PLAYERS SELECTED")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(TronColors.secondaryText)
                            Text("Add players for this week first")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(TronColors.dimText)
                        }
                        Spacer()
                    } else {
                        // Players list with inline editing
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(playersThisWeek) { player in
                                    if let playerId = player.id, playerStats[playerId] != nil {
                                        BatchPlayerRow(
                                            player: player,
                                            stats: binding(for: playerId, player: player),
                                            isExpanded: expandedPlayerId == playerId,
                                            onTap: {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    if expandedPlayerId == playerId {
                                                        expandedPlayerId = nil
                                                    } else {
                                                        expandedPlayerId = playerId
                                                    }
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                            .padding(16)
                        }
                    }
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
            .task {
                await loadAllStats()
            }
        }
    }

    private func binding(for playerId: String, player: Player) -> Binding<WeeklyStats> {
        Binding(
            get: {
                playerStats[playerId] ?? WeeklyStats(
                    playerId: playerId,
                    playerName: player.name,
                    weekNumber: statsService.currentWeek,
                    year: statsService.currentYear
                )
            },
            set: { newValue in
                playerStats[playerId] = newValue
            }
        )
    }

    private func loadAllStats() async {
        isLoading = true

        // Only load stats for players who have been selected for this week
        let weekStats = statsService.getWeeklyStatsForWeek(statsService.currentWeek)
        for stats in weekStats {
            playerStats[stats.playerId] = stats
        }

        isLoading = false
    }

    private func saveAllStats() {
        isSaving = true

        Task {
            do {
                let statsToSave = Array(playerStats.values)
                try await statsService.batchUpdateStats(statsToSave)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Error saving stats: \(error)")
            }
            await MainActor.run {
                isSaving = false
            }
        }
    }
}

// MARK: - Batch Player Row
struct BatchPlayerRow: View {
    let player: Player
    @Binding var stats: WeeklyStats
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header row (always visible)
            Button(action: onTap) {
                HStack {
                    // Use short name
                    Text(player.name.shortName)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.cyan)
                        .frame(width: 50, alignment: .leading)

                    Spacer()

                    // Quick stats summary
                    if !isExpanded {
                        HStack(spacing: 6) {
                            QuickStatPill(value: stats.dongs, label: "D", color: TronColors.cyan)
                            QuickStatPill(value: stats.drops, label: "R", color: TronColors.orange)
                            QuickStatPill(value: stats.doublePlays, label: "DP", color: TronColors.magenta)
                            QuickStatPill(value: stats.salamies, label: "S", color: TronColors.green)
                            QuickStatPill(value: stats.wins, label: "W", color: TronColors.yellow)
                        }
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(TronColors.cyan)
                        .padding(.leading, 8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            // Expanded editing area
            if isExpanded {
                VStack(spacing: 16) {
                    Divider()
                        .background(TronColors.gridLine)

                    // Full name when expanded
                    Text(player.name.uppercased())
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(TronColors.secondaryText)

                    // Stats counters in a grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        CompactStatCounter(title: "DONGS", value: $stats.dongs, color: TronColors.cyan)
                        CompactStatCounter(title: "DROPS", value: $stats.drops, color: TronColors.orange)
                        CompactStatCounter(title: "DBL PLY", value: $stats.doublePlays, color: TronColors.magenta)
                        CompactStatCounter(title: "SALAMIES", value: $stats.salamies, color: TronColors.green)
                        CompactStatCounter(title: "WINS", value: $stats.wins, color: TronColors.yellow)
                    }
                    .padding(.horizontal, 8)
                }
                .padding(.bottom, 16)
            }
        }
        .background(TronColors.cardBackground)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isExpanded ? TronColors.cyan.opacity(0.5) : TronColors.gridLine.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Quick Stat Pill
struct QuickStatPill: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
            Text("\(value)")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
        }
        .foregroundColor(value > 0 ? color : TronColors.dimText)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(value > 0 ? 0.15 : 0.05))
        .cornerRadius(4)
    }
}

// MARK: - Compact Stat Counter
struct CompactStatCounter: View {
    let title: String
    @Binding var value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(color.opacity(0.8))

            HStack(spacing: 8) {
                Button(action: { if value > 0 { value -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(value > 0 ? color : TronColors.dimText)
                }

                Text("\(value)")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                    .frame(minWidth: 30)
                    .neonGlow(color: color, radius: value > 0 ? 3 : 0)

                Button(action: { value += 1 }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
            }
        }
    }
}

#Preview {
    BatchStatsEntryView()
        .environmentObject(StatsService())
}
