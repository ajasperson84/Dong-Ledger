//
//  WeeklyPlayerSelectionView.swift
//  Dong Country Ledger 5000
//
//  Quick player selection for weekly games
//

import SwiftUI

struct WeeklyPlayerSelectionView: View {
    @EnvironmentObject var statsService: StatsService
    @Environment(\.dismiss) var dismiss

    @State private var selectedPlayerIds: Set<String> = []
    @State private var selectedField: GameField? = nil
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                TronGridBackground()

                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 4) {
                        // Special event name if any
                        if let gameWeek = statsService.currentGameWeek, let event = gameWeek.specialEvent {
                            Text(event.rawValue.uppercased())
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(TronColors.magenta)
                                .neonGlow(color: TronColors.magenta, radius: 5)
                        }

                        Text("WEEK \(statsService.currentWeekNumber)")
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(TronColors.cyan)
                            .neonGlow(color: TronColors.cyan, radius: 10)

                        // Show the date
                        if let gameWeek = statsService.currentGameWeek {
                            Text(gameWeek.formattedDate.uppercased())
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(TronColors.secondaryText)
                        }

                        Text("SELECT PLAYERS WHO PLAYED")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(TronColors.dimText)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 16)

                    // Field selection
                    VStack(spacing: 8) {
                        Text("FIELD")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(TronColors.dimText)

                        HStack(spacing: 8) {
                            ForEach(GameField.allCases, id: \.self) { field in
                                FieldChip(
                                    field: field,
                                    isSelected: selectedField == field,
                                    onTap: {
                                        print("🏟️ Field tapped: \(field.rawValue)")
                                        withAnimation(.easeOut(duration: 0.15)) {
                                            selectedField = field
                                        }
                                        print("🏟️ selectedField is now: \(selectedField?.rawValue ?? "nil")")
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    // Quick actions
                    HStack(spacing: 12) {
                        Button(action: selectAll) {
                            Text("SELECT ALL")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(TronColors.green)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(TronColors.cardBackground)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(TronColors.green.opacity(0.5), lineWidth: 1)
                                )
                        }

                        Button(action: clearAll) {
                            Text("CLEAR ALL")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(TronColors.orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(TronColors.cardBackground)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(TronColors.orange.opacity(0.5), lineWidth: 1)
                                )
                        }

                        Spacer()

                        Text("\(selectedPlayerIds.count) SELECTED")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(TronColors.cyan)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    // Player grid for quick tapping
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(statsService.players) { player in
                                PlayerSelectionTile(
                                    player: player,
                                    isSelected: selectedPlayerIds.contains(player.id ?? ""),
                                    onTap: { togglePlayer(player) }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }

                // Bottom confirm button
                VStack {
                    Spacer()

                    Button(action: confirmSelection) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .tint(TronColors.darkBackground)
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                Text("CONFIRM & ENTER STATS")
                            }
                        }
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.darkBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(selectedPlayerIds.isEmpty ? TronColors.dimText : TronColors.green)
                        .cornerRadius(12)
                        .neonGlow(color: selectedPlayerIds.isEmpty ? .clear : TronColors.green, radius: 8)
                    }
                    .disabled(selectedPlayerIds.isEmpty || isSaving)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                    .background(
                        LinearGradient(
                            colors: [TronColors.darkBackground.opacity(0), TronColors.darkBackground],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                    )
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
            .onAppear {
                loadExistingSelections()
            }
        }
    }

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
            selectedPlayerIds = Set(statsService.players.compactMap { $0.id })
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

    private func confirmSelection() {
        isSaving = true

        print("🎯 confirmSelection called")
        print("🎯 selectedField: \(selectedField?.rawValue ?? "nil")")
        print("🎯 currentWeekNumber: \(statsService.currentWeekNumber)")

        Task {
            // Save field selection
            if let field = selectedField {
                print("🎯 Saving field: \(field.rawValue)")
                do {
                    try await statsService.updateGameWeekField(weekNumber: statsService.currentWeekNumber, field: field)
                    print("🎯 Field saved successfully")
                } catch {
                    print("❌ Error saving field selection: \(error)")
                }
            } else {
                print("⚠️ No field selected, skipping field save")
            }

            // Create stats entries for all selected players
            for player in statsService.players {
                guard let playerId = player.id, selectedPlayerIds.contains(playerId) else { continue }

                do {
                    _ = try await statsService.getOrCreateWeeklyStats(
                        for: player,
                        week: statsService.currentWeek,
                        year: statsService.currentYear
                    )
                } catch {
                    print("Error creating stats for \(player.name): \(error)")
                }
            }

            await MainActor.run {
                isSaving = false
                dismiss()
            }
        }
    }
}

// MARK: - Field Chip
struct FieldChip: View {
    let field: GameField
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Image(systemName: fieldIcon)
                    .font(.system(size: 10))
                Text(field.shortName)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
            }
            .foregroundColor(isSelected ? TronColors.darkBackground : TronColors.secondaryText)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(isSelected ? TronColors.green : TronColors.surfaceBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? TronColors.green : TronColors.gridLine.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    var fieldIcon: String {
        switch field {
        case .theDam: return "water.waves"
        case .theSpreadingGrounds: return "leaf.fill"
        case .theAirfield: return "airplane"
        }
    }
}

// MARK: - Player Selection Tile
struct PlayerSelectionTile: View {
    let player: Player
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                // Selection indicator
                ZStack {
                    Circle()
                        .fill(isSelected ? TronColors.green : TronColors.surfaceBackground)
                        .frame(width: 28, height: 28)

                    Circle()
                        .stroke(isSelected ? TronColors.green : TronColors.gridLine, lineWidth: 2)
                        .frame(width: 28, height: 28)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(TronColors.darkBackground)
                    }
                }
                .neonGlow(color: isSelected ? TronColors.green : .clear, radius: 5)

                // Player name
                Text(player.name.uppercased())
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(isSelected ? TronColors.primaryText : TronColors.secondaryText)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .background(isSelected ? TronColors.cardBackground : TronColors.surfaceBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? TronColors.green.opacity(0.5) : TronColors.gridLine.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WeeklyPlayerSelectionView()
        .environmentObject(StatsService())
}
