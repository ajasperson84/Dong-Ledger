//
//  BatchStatsEntryView.swift
//  Dong Country Ledger 5000
//
//  EDIT WEEK: accordion batch entry for players' weekly stats,
//  plus editor pieces shared with PlayerStatsEntryView
//

import SwiftUI

struct BatchStatsEntryView: View {
    @EnvironmentObject var statsService: StatsService
    @Environment(\.dismiss) var dismiss

    @State private var playerStats: [String: WeeklyStats] = [:]
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var expandedPlayerId: String?
    @State private var saveError: String?

    // Only show players who were selected for this week
    var playersThisWeek: [Player] {
        let weekStats = statsService.getWeeklyStatsForWeek(statsService.currentWeek)
        let playerIds = Set(weekStats.map { $0.playerId })
        return statsService.players.filter { playerIds.contains($0.id ?? "") }
    }

    var body: some View {
        ZStack {
            SRBackground()

            ScrollView {
                VStack(spacing: 8) {
                    // Cancel / EDIT WEEK / Save All
                    ZStack {
                        Image("SR_Edit_Week_Title")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.horizontal, 70)

                        HStack(alignment: .center) {
                            Button(action: { dismiss() }) { Color.clear }
                                .buttonStyle(.srImage("Cancel_Button"))
                                .frame(width: 104, height: 44)
                                .accessibilityLabel("Cancel")

                            Spacer()

                            Button(action: saveAllStats) {
                                if isSaving {
                                    ProgressView().tint(.black)
                                } else {
                                    Color.clear
                                }
                            }
                            .buttonStyle(.srImage("Save_All_Button"))
                            .frame(width: 116, height: 48)
                            .disabled(isSaving || isLoading)
                            .accessibilityLabel("Save all")
                        }
                        .padding(.horizontal, 6)
                        .offset(y: 16)
                    }
                    .padding(.top, 8)

                    EditorDatePlaque()
                        .environmentObject(statsService)
                        .padding(.horizontal, 24)

                    if isLoading {
                        ProgressView()
                            .tint(SRColors.gold)
                            .scaleEffect(1.5)
                            .padding(.top, 40)
                    } else if playersThisWeek.isEmpty {
                        VStack(spacing: 8) {
                            Text("NO PLAYERS SELECTED")
                                .font(SRFont.display(18))
                                .foregroundColor(SRColors.text)
                            Text("Add players for this week first")
                                .font(SRFont.mono(12))
                                .foregroundColor(SRColors.gold)
                        }
                        .padding(.top, 40)
                    } else {
                        // Players list with inline editing
                        LazyVStack(spacing: 6) {
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
                        .padding(.horizontal, 8)
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .task {
            await loadAllStats()
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

// MARK: - Batch Player Row
struct BatchPlayerRow: View {
    let player: Player
    @Binding var stats: WeeklyStats
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            // Header row (always visible)
            Button(action: onTap) {
                SRArtPlate(isExpanded ? "SR_Accordion_Row_Selected" : "SR_Accordion_Row_Unselected") { size in
                    HStack(spacing: 6) {
                        Text(player.name.uppercased())
                            .font(SRFont.display(size.height * 0.26))
                            .foregroundColor(SRColors.text)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        StatChips(stats: stats, chipWidth: size.width * 0.085, chipHeight: size.height * 0.42)

                        Image(isExpanded ? "SR_Accordion_Chevron_Up" : "SR_Accordion_Chevron_Down")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: size.height * 0.30)
                    }
                    .padding(.leading, size.width * 0.07)
                    .padding(.trailing, size.width * 0.06)
                }
            }
            .buttonStyle(.plain)
            .accessibilityHint(isExpanded ? "Collapse" : "Edit stats")

            // Expanded editing area
            if isExpanded {
                StatEditorPanel(
                    dongs: $stats.dongs,
                    drops: $stats.drops,
                    doublePlays: $stats.doublePlays,
                    salamies: $stats.salamies,
                    wins: $stats.wins
                )
                .padding(.horizontal, 10)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Stat Chips
/// D / DR / DP / S / W value chips shown on each accordion row
struct StatChips: View {
    let stats: WeeklyStats
    var chipWidth: CGFloat = 30
    var chipHeight: CGFloat = 38

    var body: some View {
        HStack(spacing: 3) {
            chip("D", stats.dongs, SRColors.purple)
            chip("DR", stats.drops, TronColors.orange)
            chip("DP", stats.doublePlays, SRColors.pink)
            chip("S", stats.salamies, TronColors.green)
            chip("W", stats.wins, SRColors.gold)
        }
    }

    private func chip(_ label: String, _ value: Int, _ color: Color) -> some View {
        VStack(spacing: 0) {
            Text(label)
                .font(SRFont.display(chipHeight * 0.26))
                .srGoldText()
            Text("\(value)")
                .font(SRFont.display(chipHeight * 0.46))
                .foregroundColor(SRColors.text)
                .minimumScaleFactor(0.6)
        }
        .frame(width: chipWidth, height: chipHeight)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(LinearGradient(colors: [color.opacity(0.35), .black], startPoint: .top, endPoint: .bottom))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(color, lineWidth: 1.5)
        )
        .shadow(color: color.opacity(0.6), radius: 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) \(value)")
    }
}

// MARK: - Stat Editor Panel
/// Gold-ruled grid of +/- steppers: Dongs, Drops, Salamies, Wins, then Double Plays
struct StatEditorPanel: View {
    @Binding var dongs: Int
    @Binding var drops: Int
    @Binding var doublePlays: Int
    @Binding var salamies: Int
    @Binding var wins: Int

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                GoldStepper(title: "DONGS", value: $dongs)
                verticalRule
                GoldStepper(title: "DROPS", value: $drops)
            }
            horizontalRule
            HStack(spacing: 0) {
                GoldStepper(title: "SALAMIES", value: $salamies)
                verticalRule
                GoldStepper(title: "WINS", value: $wins)
            }
            horizontalRule
            GoldStepper(title: "DOUBLE PLAYS", value: $doublePlays)
        }
        .padding(.vertical, 4)
        .srPlate(glow: SRColors.purple, cornerRadius: 8)
    }

    private var verticalRule: some View {
        Rectangle().fill(SRColors.goldGradient).frame(width: 1.5)
    }

    private var horizontalRule: some View {
        Rectangle().fill(SRColors.goldGradient).frame(height: 1.5)
    }
}

// MARK: - Gold Stepper
struct GoldStepper: View {
    let title: String
    @Binding var value: Int

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(SRFont.display(15))
                .foregroundColor(SRColors.text)

            HStack(spacing: 10) {
                Button(action: { if value > 0 { value -= 1 } }) { Color.clear }
                    .buttonStyle(.srImage("Stepper_Minus_Button"))
                    .frame(width: 46, height: 46)
                    .opacity(value > 0 ? 1 : 0.5)
                    .accessibilityLabel("Decrease \(title.lowercased())")

                Text("\(value)")
                    .font(SRFont.display(34))
                    .foregroundColor(SRColors.text)
                    .shadow(color: .black, radius: 1, x: 0, y: 1)
                    .frame(minWidth: 40)
                    .accessibilityLabel("\(title.lowercased()) \(value)")

                Button(action: { value += 1 }) { Color.clear }
                    .buttonStyle(.srImage("Stepper_Plus_Button"))
                    .frame(width: 46, height: 46)
                    .accessibilityLabel("Increase \(title.lowercased())")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}

// MARK: - Editor Date Plaque
/// "SATURDAY · SEP 26" over "WEEK 4 · THE AIRFIELD"
struct EditorDatePlaque: View {
    @EnvironmentObject var statsService: StatsService

    private var detailLine: String {
        var parts = ["WEEK \(statsService.currentWeekNumber)"]
        if let event = statsService.currentGameWeek?.specialEvent {
            parts.append(event.rawValue.uppercased())
        }
        if let field = statsService.getFieldForWeek(statsService.currentWeekNumber) {
            parts.append(field.rawValue.uppercased())
        }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        SRArtPlate("SR_Editor_Date_Field_Plaque_Blank") { size in
            ZStack {
                Text(statsService.currentGameWeek?.dayTitle ?? "")
                    .font(SRFont.display(size.height * 0.22))
                    .foregroundColor(SRColors.text)
                    .frame(width: size.width * 0.8)
                    .position(x: size.width * 0.5, y: size.height * 0.39)
                Text(detailLine)
                    .font(SRFont.display(size.height * 0.12))
                    .srGoldText()
                    .frame(width: size.width * 0.74)
                    .position(x: size.width * 0.5, y: size.height * 0.695)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        }
    }
}

#Preview {
    BatchStatsEntryView()
        .environmentObject(StatsService())
}
