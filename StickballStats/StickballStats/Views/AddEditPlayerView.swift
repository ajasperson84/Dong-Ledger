//
//  AddEditPlayerView.swift
//  Dong Country Ledger 5000
//
//  Add or edit player details
//

import SwiftUI

struct AddEditPlayerView: View {
    @EnvironmentObject var statsService: StatsService
    @Environment(\.dismiss) var dismiss

    let player: Player?

    @State private var name: String = ""
    @State private var isPortland = false
    @State private var isSaving = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @FocusState private var isNameFocused: Bool

    // Career totals and badges as shown on the profile (editing existing LA players)
    @State private var careerValues = CareerEditValues()
    @State private var loadedCareerValues: CareerEditValues?
    @State private var baseCareerValues: CareerEditValues?

    var isEditing: Bool { player != nil }

    var body: some View {
        ZStack {
            TronGridBackground()

            ScrollView {
                VStack(spacing: 18) {
                    HStack {
                        Button(action: { dismiss() }) { Color.clear }
                            .buttonStyle(.srImage("Cancel_Button"))
                            .frame(width: 104, height: 44)
                            .accessibilityLabel("Cancel")
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)

                    Image(isEditing ? "SR_Edit_Player_Title" : "SR_Add_Player_Title")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, 20)
                        .accessibilityLabel(isEditing ? "Edit player" : "Add player")

                    // Name field on the gold plate
                    SRArtPlate(isNameFocused ? "SR_Player_Name_Field_Selected" : "SR_Player_Name_Field_Unselected") { size in
                        TextField("", text: $name, prompt: Text("PLAYER NAME").foregroundColor(SRColors.gold.opacity(0.6)))
                            .font(SRFont.display(size.height * 0.20))
                            .foregroundColor(SRColors.text)
                            .multilineTextAlignment(.center)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                            .focused($isNameFocused)
                            .frame(width: size.width * 0.74)
                            .position(x: size.width * 0.5, y: size.height * 0.44)
                    }
                    .padding(.horizontal, 12)

                    // Portland players only appear for the Coattail Classic
                    Toggle(isOn: $isPortland) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("PORTLAND CHAPTER")
                                .font(SRFont.display(15))
                                .srGoldText()
                            Text("Coattail Classic only · not in LA stats")
                                .font(SRFont.mono(11))
                                .foregroundColor(SRColors.text.opacity(0.8))
                        }
                    }
                    .tint(SRColors.purple)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .srPlate(glow: SRColors.purple)
                    .padding(.horizontal, 24)

                    if loadedCareerValues != nil {
                        careerEditor
                    }

                    // Add Player / Save Changes
                    Button(action: savePlayer) {
                        GeometryReader { geo in
                            ZStack {
                                Image(systemName: isEditing ? "checkmark" : "plus")
                                    .font(.system(size: geo.size.height * 0.16, weight: .black))
                                    .foregroundColor(.black.opacity(0.75))
                                    .position(x: geo.size.width * 0.205, y: geo.size.height * 0.48)
                                Group {
                                    if isSaving {
                                        ProgressView().tint(SRColors.text)
                                    } else {
                                        Text(isEditing ? "SAVE CHANGES" : "ADD PLAYER")
                                            .font(SRFont.slab(geo.size.height * 0.15))
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
                    .padding(.horizontal, 20)
                    .opacity(trimmedName.isEmpty ? 0.5 : 1)
                    .disabled(trimmedName.isEmpty || isSaving)
                }
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            if let player = player {
                name = player.name
                isPortland = player.isPortland
                loadCareerValues(for: player)
            }
        }
        .alert("ERROR", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Career & Badges

    /// Career stats are tracked under the player's canonical name (e.g. "Candy" -> "Candyman")
    private var canonicalName: String {
        PlayerAliases.canonicalName(for: player?.name ?? name)
    }

    private func loadCareerValues(for player: Player) {
        guard !player.isPortland else { return }
        let canonical = PlayerAliases.canonicalName(for: player.name)

        // Calculated values with no admin correction
        let base = HistoricalData.calculateCareerStats(currentSeasonStats: statsService.yearlyStats)
            .first { $0.playerName == canonical } ?? CareerStats(playerName: canonical)
        let baseValues = CareerEditValues(
            stats: base,
            achievements: AchievementsCalculator.calculateAchievements(for: canonical, careerStats: base)
        )

        // What the profile currently shows, including any saved correction
        var current = baseValues
        if let adjustment = statsService.careerAdjustments[canonical] {
            var adjusted = base
            adjusted.apply(adjustment)
            current = CareerEditValues(
                stats: adjusted,
                achievements: AchievementsCalculator.calculateAchievements(for: canonical, careerStats: adjusted, adjustment: adjustment)
            )
        }

        baseCareerValues = baseValues
        loadedCareerValues = current
        careerValues = current
    }

    private var careerEditor: some View {
        VStack(spacing: 10) {
            Text("CAREER TOTALS")
                .font(SRFont.slab(18))
                .srGoldText()

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)], spacing: 0) {
                GoldStepper(title: "DONGS", value: $careerValues.dongs)
                GoldStepper(title: "DOUBLE PLAYS", value: $careerValues.doublePlays)
                GoldStepper(title: "SALAMIES", value: $careerValues.salamies)
                GoldStepper(title: "DONG ROBS", value: $careerValues.dongRobs)
                GoldStepper(title: "WINS", value: $careerValues.wins)
                GoldStepper(title: "DROPS", value: $careerValues.drops)
                GoldStepper(title: "YFSLA TITLES", value: $careerValues.yfslaChampionships)
            }
            .srPlate(glow: SRColors.purple)

            Text("BADGES")
                .font(SRFont.slab(18))
                .srGoldText()
                .padding(.top, 8)

            VStack(spacing: 4) {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)], spacing: 0) {
                    GoldStepper(title: "MVP", value: $careerValues.mvp)
                    GoldStepper(title: "DONG KING", value: $careerValues.dongKing)
                    GoldStepper(title: "ROOKIE OF YEAR", value: $careerValues.rookieOfYear)
                }

                badgeToggle("COATTAILS", isOn: $careerValues.coattails)
                badgeToggle("GALACTICS", isOn: $careerValues.galactics)
                badgeToggle("WIDE OPEN", isOn: $careerValues.wideOpen)

                Text("100–500 Club and Salami Club badges follow career dongs and salamies.")
                    .font(SRFont.mono(10))
                    .foregroundColor(SRColors.text.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(10)
            }
            .srPlate(glow: SRColors.purple)

            if careerValues != loadedCareerValues {
                Text("Tap Save Changes to apply")
                    .font(SRFont.mono(11))
                    .foregroundColor(SRColors.pink)
            }
        }
        .padding(.horizontal, 12)
    }

    private func badgeToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(SRFont.display(15))
                .foregroundColor(SRColors.text)
        }
        .tint(SRColors.purple)
        .padding(.horizontal, 18)
        .padding(.vertical, 4)
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    private func savePlayer() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        isSaving = true

        Task {
            do {
                let trimmedName = name.trimmingCharacters(in: .whitespaces)

                if var existingPlayer = player {
                    // Update existing player
                    existingPlayer.name = trimmedName
                    existingPlayer.teamName = isPortland ? Player.portlandChapter : nil
                    try await statsService.updatePlayer(existingPlayer)

                    // Career / badge corrections, saved as differences from the calculated values
                    if let loaded = loadedCareerValues, let base = baseCareerValues, careerValues != loaded {
                        try await statsService.saveCareerAdjustment(
                            careerValues.adjustment(for: canonicalName, base: base)
                        )
                    }
                } else {
                    // Add new player
                    try await statsService.addPlayer(
                        name: trimmedName,
                        teamName: isPortland ? Player.portlandChapter : nil
                    )
                }

                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }

            await MainActor.run {
                isSaving = false
            }
        }
    }
}

// MARK: - Career Edit Values
/// The career totals and badges an admin can edit, as the profile shows them
struct CareerEditValues: Equatable {
    var dongs = 0
    var drops = 0
    var doublePlays = 0
    var salamies = 0
    var wins = 0
    var dongRobs = 0
    var yfslaChampionships = 0
    var mvp = 0
    var dongKing = 0
    var rookieOfYear = 0
    var coattails = false
    var galactics = false
    var wideOpen = false

    init() {}

    init(stats: CareerStats, achievements: PlayerAchievements) {
        dongs = stats.totalDongs
        drops = stats.totalDrops
        doublePlays = stats.totalDoublePlays
        salamies = stats.totalSalamies
        wins = stats.totalWins
        dongRobs = stats.totalDongRobs
        yfslaChampionships = achievements.yfslaChampCount
        mvp = achievements.mvpCount
        dongKing = achievements.dongKingCount
        rookieOfYear = achievements.rookieOfYearCount
        coattails = achievements.hasCoattails
        galactics = achievements.hasGalactics
        wideOpen = achievements.hasWideOpen
    }

    /// The correction that turns the calculated values (base) into these
    func adjustment(for playerName: String, base: CareerEditValues) -> CareerAdjustment {
        var adjustment = CareerAdjustment(playerName: playerName)
        adjustment.dongs = dongs - base.dongs
        adjustment.drops = drops - base.drops
        adjustment.doublePlays = doublePlays - base.doublePlays
        adjustment.salamies = salamies - base.salamies
        adjustment.wins = wins - base.wins
        adjustment.dongRobs = dongRobs - base.dongRobs
        adjustment.yfslaChampionships = yfslaChampionships - base.yfslaChampionships
        adjustment.mvp = mvp - base.mvp
        adjustment.dongKing = dongKing - base.dongKing
        adjustment.rookieOfYear = rookieOfYear - base.rookieOfYear
        adjustment.coattails = coattails == base.coattails ? nil : coattails
        adjustment.galactics = galactics == base.galactics ? nil : galactics
        adjustment.wideOpen = wideOpen == base.wideOpen ? nil : wideOpen
        return adjustment
    }
}

// MARK: - Tron Text Field
struct TronTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let color: Color
    var keyboardType: UIKeyboardType = .default

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(color.opacity(0.8))

            TextField(placeholder, text: $text)
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(TronColors.primaryText)
                .keyboardType(keyboardType)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .focused($isFocused)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(TronColors.surfaceBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isFocused ? color : color.opacity(0.3), lineWidth: isFocused ? 2 : 1)
                )
                .neonGlow(color: color, radius: isFocused ? 5 : 0)
        }
    }
}

#Preview {
    AddEditPlayerView(player: nil)
        .environmentObject(StatsService())
}
