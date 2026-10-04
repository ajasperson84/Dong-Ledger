//
//  WeeklyPlayerSelectionView.swift
//  Dong Country Ledger 5000
//
//  Pick who played this week and the field (Stickball Rich skin)
//

import SwiftUI

struct WeeklyPlayerSelectionView: View {
    @EnvironmentObject var statsService: StatsService
    @Environment(\.dismiss) var dismiss

    @State private var selectedPlayerIds: Set<String> = []
    @State private var selectedField: GameField? = nil
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var removalsWithStats: [String] = []

    var body: some View {
        ZStack(alignment: .bottom) {
            SRBackground()

            ScrollView {
                VStack(spacing: 10) {
                    HStack {
                        Button(action: { dismiss() }) { Color.clear }
                            .buttonStyle(.srImage("Cancel_Button"))
                            .frame(width: 104, height: 44)
                            .accessibilityLabel("Cancel")
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)

                    Image("SR_Weekly_Banner")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, 60)
                        .accessibilityHidden(true)

                    if let event = statsService.currentGameWeek?.specialEvent {
                        Text(event.rawValue.uppercased())
                            .font(SRFont.display(16))
                            .srGoldText()
                    }

                    EditorDatePlaque()
                        .environmentObject(statsService)
                        .padding(.horizontal, 24)

                    Text("WHO PLAYED?")
                        .font(SRFont.slab(20))
                        .foregroundColor(SRColors.text)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)

                    // Field plates
                    VStack(spacing: 4) {
                        Text("FIELD")
                            .font(SRFont.display(13))
                            .srGoldText()
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4)], spacing: 2) {
                            ForEach(GameField.allCases, id: \.self) { field in
                                FieldChip(
                                    field: field,
                                    isSelected: selectedField == field,
                                    onTap: {
                                        withAnimation(.easeOut(duration: 0.15)) {
                                            selectedField = field
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 12)

                    // Quick actions
                    HStack(spacing: 10) {
                        quickAction("SELECT ALL", action: selectAll)
                        quickAction("CLEAR ALL", action: clearAll)
                        Spacer()
                        Text("\(selectedPlayerIds.count) SELECTED")
                            .font(SRFont.display(14))
                            .srGoldText()
                    }
                    .padding(.horizontal, 18)

                    // Players
                    VStack(spacing: -26) {
                        ForEach(statsService.laPlayers) { player in
                            selectionRow(player)
                        }
                    }
                    .padding(.horizontal, 8)

                    // Portland chapter joins for the Coattail Classic
                    if showsPortland {
                        Text("PORTLAND CHAPTER")
                            .font(SRFont.slab(16))
                            .srGoldText()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            .padding(.top, 8)

                        if statsService.portlandPlayers.isEmpty {
                            Text("Add Portland players in the Players tab")
                                .font(SRFont.mono(11))
                                .foregroundColor(SRColors.gold)
                        } else {
                            VStack(spacing: -26) {
                                ForEach(statsService.portlandPlayers) { player in
                                    selectionRow(player)
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                }
                .padding(.bottom, 140)
            }

            confirmButton
        }
        .onAppear {
            loadExistingSelections()
        }
        .alert("COULDN'T SAVE", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveError ?? "")
        }
        .confirmationDialog(
            "Remove \(removalsWithStats.joined(separator: ", ")) from this week?",
            isPresented: Binding(
                get: { !removalsWithStats.isEmpty },
                set: { if !$0 { removalsWithStats = [] } }
            ),
            titleVisibility: .visible
        ) {
            Button("Remove and Delete Their Stats", role: .destructive) {
                removalsWithStats = []
                confirmSelection()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Stats already entered for them this week will be deleted.")
        }
    }

    /// Entries for players who were in this week's game but are now unchecked
    private var entriesToRemove: [WeeklyStats] {
        statsService.getWeeklyStatsForWeek(statsService.currentWeek)
            .filter { !selectedPlayerIds.contains($0.playerId) }
    }

    /// Something to save: players picked, players to remove, or a field change
    private var hasChanges: Bool {
        !selectedPlayerIds.isEmpty || !entriesToRemove.isEmpty
            || selectedField != statsService.getFieldForWeek(statsService.currentWeekNumber)
    }

    // MARK: - Pieces

    private var showsPortland: Bool {
        statsService.currentGameWeek?.specialEvent?.includesPortland ?? false
    }

    private func selectionRow(_ player: Player) -> some View {
        PlayerSelectionTile(
            player: player,
            isSelected: selectedPlayerIds.contains(player.id ?? ""),
            onTap: { togglePlayer(player) }
        )
    }

    private func quickAction(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(SRFont.display(12))
                .srGoldText()
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .srPlate(cornerRadius: 6)
        }
        .buttonStyle(.plain)
    }

    /// Gold primary-action plate pinned to the bottom
    private var confirmButton: some View {
        Button(action: confirmTapped) {
            GeometryReader { geo in
                ZStack {
                    Image(systemName: "checkmark")
                        .font(.system(size: geo.size.height * 0.16, weight: .black))
                        .foregroundColor(.black.opacity(0.75))
                        .position(x: geo.size.width * 0.205, y: geo.size.height * 0.48)
                    Group {
                        if isSaving {
                            ProgressView().tint(SRColors.text)
                        } else {
                            Text("SAVE PLAYERS")
                                .font(SRFont.slab(geo.size.height * 0.13))
                                .foregroundColor(SRColors.text)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                    }
                    .frame(width: geo.size.width * 0.52)
                    .position(x: geo.size.width * 0.55, y: geo.size.height * 0.48)
                }
            }
        }
        .buttonStyle(.srImage("Primary_Action_Button_Blank"))
        .padding(.horizontal, 24)
        .opacity(hasChanges ? 1 : 0.5)
        .disabled(!hasChanges || isSaving)
        .background(alignment: .bottom) {
            LinearGradient(colors: [.clear, .black.opacity(0.85)], startPoint: .top, endPoint: .bottom)
                .frame(height: 170)
                .ignoresSafeArea(edges: .bottom)
                .allowsHitTesting(false)
        }
        .accessibilityLabel("Confirm players")
    }

    // MARK: - Actions

    private func togglePlayer(_ player: Player) {
        guard let playerId = player.id else { return }
        withAnimation(.easeOut(duration: 0.15)) {
            if selectedPlayerIds.contains(playerId) {
                selectedPlayerIds.remove(playerId)
            } else {
                selectedPlayerIds.insert(playerId)
            }
        }
    }

    private func selectAll() {
        withAnimation(.easeOut(duration: 0.2)) {
            selectedPlayerIds = Set(statsService.selectablePlayers.compactMap { $0.id })
        }
    }

    private func clearAll() {
        withAnimation(.easeOut(duration: 0.2)) {
            selectedPlayerIds.removeAll()
        }
    }

    private func loadExistingSelections() {
        // Pre-select players who already have stats for this week
        let existingStats = statsService.getWeeklyStatsForWeek(statsService.currentWeek)
        selectedPlayerIds = Set(existingStats.map { $0.playerId })

        // Load existing field selection
        selectedField = statsService.getFieldForWeek(statsService.currentWeekNumber)
    }

    /// Asks first if unchecking would delete recorded stats
    private func confirmTapped() {
        let withStats = entriesToRemove.filter { $0.hasAnyStats }
        if withStats.isEmpty {
            confirmSelection()
        } else {
            removalsWithStats = withStats.map { entry in
                statsService.players.first { $0.id == entry.playerId }?.name ?? entry.playerName
            }
        }
    }

    private func confirmSelection() {
        isSaving = true
        let removals = entriesToRemove

        Task { @MainActor in
            var failures: [String] = []

            // Save field selection
            if let field = selectedField {
                do {
                    try await statsService.updateGameWeekField(weekNumber: statsService.currentWeekNumber, field: field)
                } catch {
                    failures.append("Field: \(error.localizedDescription)")
                }
            }

            // Take unchecked players out of this week's game
            for entry in removals {
                do {
                    try await statsService.removeWeeklyStats(entry)
                } catch {
                    failures.append("\(entry.playerName): \(error.localizedDescription)")
                }
            }

            // Create stats entries for all selected players
            for player in statsService.selectablePlayers {
                guard let playerId = player.id, selectedPlayerIds.contains(playerId) else { continue }

                do {
                    _ = try await statsService.getOrCreateWeeklyStats(
                        for: player,
                        week: statsService.currentWeek,
                        year: statsService.currentYear
                    )
                } catch {
                    failures.append("\(player.name): \(error.localizedDescription)")
                }
            }

            isSaving = false
            if failures.isEmpty {
                dismiss()
            } else {
                // Stay open so nothing silently disappears
                saveError = failures.prefix(3).joined(separator: "\n")
                    + (failures.count > 3 ? "\n…and \(failures.count - 3) more" : "")
            }
        }
    }
}

// MARK: - Field Chip
/// Blank category plate with the field's icon and name; Uncle Kimmy's Playhouse is the night game
struct FieldChip: View {
    let field: GameField
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(isSelected ? "SR_Selected_Blank" : "SR_Unselected_Blank")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay(
                    HStack(spacing: 5) {
                        Image(systemName: field.icon)
                            .font(.system(size: 13))
                            .foregroundColor(field.isNightGame ? SRColors.goldLight : SRColors.gold)
                        Text(field.rawValue.uppercased())
                            .font(SRFont.display(13))
                            .foregroundColor(SRColors.text)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    .padding(.horizontal, 22)
                )
                .frame(height: isSelected ? 52 : 46)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(field.isNightGame ? "\(field.rawValue), night game" : field.rawValue)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Player Selection Tile
/// Gold accordion row with a diamond checkbox
struct PlayerSelectionTile: View {
    let player: Player
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            SRArtPlate(isSelected ? "SR_Accordion_Row_Selected" : "SR_Accordion_Row_Unselected") { size in
                HStack(spacing: 12) {
                    Image(isSelected ? "SR_PIN_Cell_Filled" : "SR_PIN_Cell_Empty")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size.height * 0.40, height: size.height * 0.40)

                    Text(player.name.uppercased())
                        .font(SRFont.display(size.height * 0.24))
                        .foregroundColor(isSelected ? SRColors.text : SRColors.text.opacity(0.7))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)

                    Spacer(minLength: 0)
                }
                .padding(.leading, size.width * 0.07)
                .padding(.trailing, size.width * 0.06)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(player.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    WeeklyPlayerSelectionView()
        .environmentObject(StatsService())
}
