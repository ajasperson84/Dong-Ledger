//
//  PlayersView.swift
//  StickballStats
//
//  Player management view
//

import SwiftUI

struct PlayersView: View {
    @EnvironmentObject var statsService: StatsService
    @EnvironmentObject var adminService: AdminService
    @State private var showingAddPlayer = false
    @State private var selectedPlayer: Player?
    @State private var showingDeleteConfirmation = false
    @State private var playerToDelete: Player?
    @State private var selectedCareerStats: CareerStats?
    @State private var showingAdminPIN = false

    // Get all career stats for lookup (includes current season from Firebase)
    private var allCareerStats: [CareerStats] {
        HistoricalData.calculateCareerStats(currentSeasonStats: statsService.yearlyStats)
    }

    private func playerRow(_ player: Player, careerStats: CareerStats?) -> some View {
        PlayerManagementRow(
            player: player,
            careerStats: careerStats,
            isAdminMode: adminService.isAdminMode,
            onTap: {
                if let stats = careerStats {
                    selectedCareerStats = stats
                }
            },
            onEdit: { selectedPlayer = player },
            onDelete: {
                playerToDelete = player
                showingDeleteConfirmation = true
            }
        )
    }

    // Find career stats for a player by name
    private func careerStatsFor(_ player: Player) -> CareerStats? {
        let canonicalName = PlayerAliases.canonicalName(for: player.name)
        return allCareerStats.first { $0.playerName == canonicalName }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                SRBackground()

                ScrollView {
                    VStack(spacing: 4) {
                        SRHeader(banner: "SR_Players_Banner", bannerWidth: 0.8)
                            .overlay(alignment: .bottomLeading) {
                                adminToggle
                                    .padding(.leading, 8)
                                    .padding(.bottom, 4)
                            }

                        // Add player (admin mode)
                        if adminService.isAdminMode {
                            Button(action: { showingAddPlayer = true }) { Color.clear }
                                .buttonStyle(.srImage("Add_New_Player_Button"))
                                .padding(.horizontal, 40)
                                .accessibilityLabel("Add new player")
                        }

                        if statsService.players.isEmpty {
                            Text(adminService.isAdminMode ? "Tap Add New Player to get started" : "No players added yet")
                                .font(SRFont.mono(12))
                                .foregroundColor(SRColors.gold)
                                .padding(.top, 24)
                        } else {
                            LazyVStack(spacing: 2) {
                                ForEach(statsService.laPlayers) { player in
                                    playerRow(player, careerStats: careerStatsFor(player))
                                }

                                // Visiting Portland chapter (Coattail Classic only, no LA career stats)
                                if !statsService.portlandPlayers.isEmpty {
                                    Text("PORTLAND CHAPTER")
                                        .font(SRFont.slab(16))
                                        .srGoldText()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, 12)
                                        .padding(.leading, 12)

                                    ForEach(statsService.portlandPlayers) { player in
                                        playerRow(player, careerStats: nil)
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                        }

                        SRFooterLogo()
                    }
                    .padding(.bottom, 12)
                }

                if showingDeleteConfirmation, let player = playerToDelete {
                    DeletePlayerModal(
                        playerName: player.name,
                        onCancel: {
                            showingDeleteConfirmation = false
                            playerToDelete = nil
                        },
                        onDelete: {
                            deletePlayer(player)
                            showingDeleteConfirmation = false
                            playerToDelete = nil
                        }
                    )
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: showingDeleteConfirmation)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingAddPlayer) {
                AddEditPlayerView(player: nil)
                    .environmentObject(statsService)
            }
            .sheet(item: $selectedPlayer) { player in
                AddEditPlayerView(player: player)
                    .environmentObject(statsService)
            }
            .sheet(isPresented: $showingAdminPIN) {
                AdminPINEntryView()
                    .environmentObject(adminService)
            }
            .sheet(item: $selectedCareerStats) { stats in
                PlayerCareerDetailView(stats: stats)
            }
        }
    }

    /// Padlock when locked; gold ADMIN plate when unlocked (tap to lock again)
    private var adminToggle: some View {
        Button(action: {
            if adminService.isAdminMode {
                adminService.logout()
            } else {
                showingAdminPIN = true
            }
        }) {
            Color.clear
        }
        .buttonStyle(.srImage(adminService.isAdminMode ? "Admin_Unlocked" : "Admin_Locked"))
        .frame(width: adminService.isAdminMode ? 104 : 54, height: 50)
        .accessibilityLabel(adminService.isAdminMode ? "Admin mode on. Tap to lock" : "Unlock admin mode")
    }

    private func deletePlayer(_ player: Player) {
        Task {
            do {
                try await statsService.deletePlayer(player)
            } catch {
                print("Error deleting player: \(error)")
            }
        }
    }
}

// MARK: - Player Management Row
/// Directory row: medallion initial, name, career line, and admin edit/delete buttons
struct PlayerManagementRow: View {
    let player: Player
    let careerStats: CareerStats?
    let isAdminMode: Bool
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        SRArtPlate("SR_Player_Directory_Row_Unselected") { size in
            ZStack(alignment: .topLeading) {
                // Whole-row tap opens the career profile
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture(perform: onTap)

                Group {
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(SRFont.slab(size.height * 0.30))
                        .foregroundStyle(
                            LinearGradient(colors: [.white, Color(white: 0.72), .white], startPoint: .top, endPoint: .bottom)
                        )
                        .shadow(color: .black, radius: 1, x: 0, y: 1)
                        .position(x: size.width * 0.121, y: size.height * 0.545)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.name.uppercased())
                            .font(SRFont.slab(size.height * 0.20))
                            .foregroundColor(SRColors.text)
                            .shadow(color: .black, radius: 1, x: 0, y: 1)
                        if let stats = careerStats {
                            Text("\(stats.totalDongs) CAREER DONGS • \(stats.seasonsPlayed) SEASONS")
                                .font(SRFont.mono(size.height * 0.12))
                                .foregroundColor(SRColors.gold)
                        } else if player.isPortland {
                            Text("PORTLAND CHAPTER")
                                .font(SRFont.mono(size.height * 0.12))
                                .foregroundColor(SRColors.pink)
                        }
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(width: size.width * (isAdminMode ? 0.46 : 0.62), alignment: .leading)
                    .offset(x: size.width * 0.22, y: size.height * 0.33)
                }
                .allowsHitTesting(false)

                // Edit / delete sit over the row's chevron in admin mode
                if isAdminMode {
                    HStack(spacing: 2) {
                        Button(action: onEdit) { Color.clear }
                            .buttonStyle(.srImage("Edit_Button"))
                            .frame(width: size.height * 0.56, height: size.height * 0.56)
                            .accessibilityLabel("Edit \(player.name)")
                        Button(action: onDelete) { Color.clear }
                            .buttonStyle(.srImage("Delete_Button"))
                            .frame(width: size.height * 0.56, height: size.height * 0.56)
                            .accessibilityLabel("Delete \(player.name)")
                    }
                    .position(x: size.width * 0.84, y: size.height * 0.55)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityAction(named: "View career", onTap)
    }
}

// MARK: - Delete Player Modal
struct DeletePlayerModal: View {
    let playerName: String
    let onCancel: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture(perform: onCancel)

            SRArtPlate("SR_Delete_Modal_Blank") { size in
                VStack(spacing: size.height * 0.05) {
                    Spacer(minLength: size.height * 0.24)

                    Text("Remove \(playerName)?")
                        .font(SRFont.display(size.height * 0.07))
                        .foregroundColor(SRColors.text)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)

                    Text("Their stats are kept, but they won't appear in active lists.")
                        .font(SRFont.mono(size.height * 0.04))
                        .foregroundColor(SRColors.gold)
                        .multilineTextAlignment(.center)

                    Spacer(minLength: 0)

                    HStack(spacing: size.width * 0.04) {
                        Button(action: onCancel) { Color.clear }
                            .buttonStyle(.srImage("Cancel_Button"))
                            .accessibilityLabel("Cancel")
                        Button(action: onDelete) { Color.clear }
                            .buttonStyle(.srImage("Delete_Action_Button"))
                            .accessibilityLabel("Delete")
                    }
                    .frame(height: size.height * 0.16)
                    .padding(.bottom, size.height * 0.08)
                }
                .padding(.horizontal, size.width * 0.12)
            }
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - Admin PIN Entry View
struct AdminPINEntryView: View {
    @EnvironmentObject var adminService: AdminService
    @Environment(\.dismiss) var dismiss
    @State private var pin = ""
    @State private var showError = false

    var body: some View {
        ZStack {
            TronGridBackground()

            VStack(spacing: 18) {
                HStack {
                    Button(action: { dismiss() }) { Color.clear }
                        .buttonStyle(.srImage("Cancel_Button"))
                        .frame(width: 104, height: 44)
                        .accessibilityLabel("Cancel")
                    Spacer()
                }
                .padding(.horizontal, 12)

                Image("SR_Admin_PIN_Title")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 30)

                // PIN cells
                HStack(spacing: 10) {
                    ForEach(0..<4) { index in
                        Image(index < pin.count ? "SR_PIN_Cell_Filled" : "SR_PIN_Cell_Empty")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 58, height: 58)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(pin.count) of 4 digits entered")

                Text(showError ? "INCORRECT PIN" : " ")
                    .font(SRFont.display(14))
                    .foregroundColor(TronColors.orange)

                // Number pad
                VStack(spacing: 10) {
                    ForEach(0..<3) { row in
                        HStack(spacing: 16) {
                            ForEach(1...3, id: \.self) { col in
                                let number = row * 3 + col
                                PINButton(number: "\(number)") {
                                    addDigit("\(number)")
                                }
                            }
                        }
                    }
                    HStack(spacing: 16) {
                        Color.clear
                            .frame(width: 76, height: 76)

                        PINButton(number: "0") {
                            addDigit("0")
                        }

                        Button(action: deleteDigit) { Color.clear }
                            .buttonStyle(.srImage("PIN_Backspace"))
                            .frame(width: 76, height: 76)
                            .accessibilityLabel("Delete digit")
                    }
                }

                Spacer()
            }
            .padding(.top, 16)
        }
        .presentationDetents([.large])
    }

    private func addDigit(_ digit: String) {
        guard pin.count < 4 else { return }
        showError = false
        pin += digit

        if pin.count == 4 {
            // Attempt authentication
            if adminService.authenticate(pin: pin) {
                dismiss()
            } else {
                showError = true
                pin = ""
            }
        }
    }

    private func deleteDigit() {
        guard !pin.isEmpty else { return }
        pin.removeLast()
        showError = false
    }
}

// MARK: - PIN Button
/// Gold keypad key with a diamond digit
struct PINButton: View {
    let number: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            DiamondNumber(value: Int(number) ?? 0, height: 34)
        }
        .buttonStyle(.srImage("PIN_Key"))
        .frame(width: 76, height: 76)
        .accessibilityLabel(number)
    }
}

#Preview {
    PlayersView()
        .environmentObject(StatsService())
        .environmentObject(AdminService.shared)
}
