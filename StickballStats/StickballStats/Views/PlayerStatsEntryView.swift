//
//  PlayerStatsEntryView.swift
//  StickballStats
//
//  Individual player stats entry view
//

import SwiftUI

struct PlayerStatsEntryView: View {
    @EnvironmentObject var statsService: StatsService
    @Environment(\.dismiss) var dismiss

    let player: Player

    @State private var stats: WeeklyStats?
    @State private var dongs = 0
    @State private var drops = 0
    @State private var doublePlays = 0
    @State private var salamies = 0
    @State private var wins = 0
    @State private var isLoading = true
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                TronGridBackground()

                VStack(spacing: 24) {
                    // Player header
                    VStack(spacing: 8) {
                        Text(player.name.uppercased())
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(TronColors.cyan)
                            .neonGlow(color: TronColors.cyan, radius: 10)

                        Text("WEEK \(statsService.currentWeek), \(statsService.currentYear)")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(TronColors.secondaryText)
                    }
                    .padding(.top, 20)

                    if isLoading {
                        ProgressView()
                            .tint(TronColors.cyan)
                            .scaleEffect(1.5)
                            .frame(maxHeight: .infinity)
                    } else {
                        // Stats entry grid
                        VStack(spacing: 20) {
                            HStack(spacing: 30) {
                                StatCounter(title: "Dongs", value: $dongs, color: TronColors.cyan)
                                StatCounter(title: "Drops", value: $drops, color: TronColors.orange)
                            }

                            HStack(spacing: 30) {
                                StatCounter(title: "Double Plays", value: $doublePlays, color: TronColors.magenta)
                                StatCounter(title: "Salamies", value: $salamies, color: TronColors.green)
                            }

                            StatCounter(title: "Wins", value: $wins, color: TronColors.yellow)
                        }
                        .padding(24)
                        .background(TronColors.cardBackground)
                        .cornerRadius(16)
                        .neonBorder(color: TronColors.cyan.opacity(0.5))
                        .padding(.horizontal, 16)

                        Spacer()

                        // Save button
                        Button(action: saveStats) {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .tint(TronColors.darkBackground)
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "checkmark.circle")
                                    Text("SAVE STATS")
                                }
                            }
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(TronColors.darkBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(TronColors.cyan)
                            .cornerRadius(12)
                            .neonGlow(color: TronColors.cyan, radius: 10)
                        }
                        .disabled(isSaving)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
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
                await loadStats()
            }
        }
    }

    private func loadStats() async {
        isLoading = true
        do {
            let loadedStats = try await statsService.getOrCreateWeeklyStats(
                for: player,
                week: statsService.currentWeek,
                year: statsService.currentYear
            )
            stats = loadedStats
            dongs = loadedStats.dongs
            drops = loadedStats.drops
            doublePlays = loadedStats.doublePlays
            salamies = loadedStats.salamies
            wins = loadedStats.wins
        } catch {
            print("Error loading stats: \(error)")
        }
        isLoading = false
    }

    private func saveStats() {
        guard var updatedStats = stats else { return }

        isSaving = true
        updatedStats.dongs = dongs
        updatedStats.drops = drops
        updatedStats.doublePlays = doublePlays
        updatedStats.salamies = salamies
        updatedStats.wins = wins

        Task {
            do {
                try await statsService.updateWeeklyStats(updatedStats)
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

#Preview {
    PlayerStatsEntryView(player: Player(name: "Test Player", jerseyNumber: 42))
        .environmentObject(StatsService())
}
