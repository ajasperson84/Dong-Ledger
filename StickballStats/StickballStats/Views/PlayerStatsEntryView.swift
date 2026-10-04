//
//  PlayerStatsEntryView.swift
//  StickballStats
//
//  Individual player stats entry (Stickball Rich skin)
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
    @State private var saveError: String?

    var body: some View {
        ZStack {
            SRBackground()

            ScrollView {
                VStack(spacing: 12) {
                    // Player name and week on the header plaque
                    SRArtPlate("SR_Player_Header_Plaque_Blank") { size in
                        ZStack {
                            Text(player.name.uppercased())
                                .font(SRFont.display(size.height * 0.20))
                                .foregroundColor(SRColors.text)
                                .shadow(color: .black, radius: 1, x: 0, y: 1)
                                .frame(width: size.width * 0.72)
                                .position(x: size.width * 0.5, y: size.height * 0.35)
                            Text(detailLine)
                                .font(SRFont.display(size.height * 0.09))
                                .srGoldText()
                                .frame(width: size.width * 0.66)
                                .position(x: size.width * 0.5, y: size.height * 0.655)
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 24)

                    if isLoading {
                        ProgressView()
                            .tint(SRColors.gold)
                            .scaleEffect(1.5)
                            .padding(.top, 40)
                    } else {
                        StatEditorPanel(
                            dongs: $dongs,
                            drops: $drops,
                            doublePlays: $doublePlays,
                            salamies: $salamies,
                            wins: $wins
                        )
                        .padding(.horizontal, 14)

                        // Save / Cancel
                        Button(action: saveStats) {
                            if isSaving {
                                ProgressView().tint(.white)
                            } else {
                                Color.clear
                            }
                        }
                        .buttonStyle(.srImage("Save_Stats_Button"))
                        .padding(.horizontal, 24)
                        .disabled(isSaving || stats == nil)
                        .accessibilityLabel("Save stats")

                        Button(action: { dismiss() }) { Color.clear }
                            .buttonStyle(.srImage("Cancel_Button"))
                            .frame(width: 150, height: 60)
                            .accessibilityLabel("Cancel")
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .task {
            await loadStats()
        }
        .alert("COULDN'T SAVE", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveError ?? "")
        }
    }

    /// "SATURDAY · SEP 26 · WEEK 4 · THE AIRFIELD"
    private var detailLine: String {
        var parts: [String] = []
        if let gameWeek = statsService.currentGameWeek {
            parts.append(gameWeek.dayTitle)
        }
        parts.append("WEEK \(statsService.currentWeekNumber)")
        if let field = statsService.getFieldForWeek(statsService.currentWeekNumber) {
            parts.append(field.rawValue.uppercased())
        }
        return parts.joined(separator: " · ")
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
            saveError = error.localizedDescription
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
                await MainActor.run {
                    saveError = error.localizedDescription
                }
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
