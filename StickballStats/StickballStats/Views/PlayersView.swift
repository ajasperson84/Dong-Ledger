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

    // Get all career stats for lookup
    private let allCareerStats = HistoricalData.calculateCareerStats()

    // Find career stats for a player by name
    private func careerStatsFor(_ player: Player) -> CareerStats? {
        let canonicalName = PlayerAliases.canonicalName(for: player.name)
        return allCareerStats.first { $0.playerName == canonicalName }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                TronGridBackground()

                VStack(spacing: 0) {
                    // Quick add bar (only show in admin mode)
                    if adminService.isAdminMode {
                        QuickAddPlayerBar(onAdd: { showingAddPlayer = true })
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }

                    if statsService.players.isEmpty {
                        EmptyStateView(
                            icon: "person.3",
                            title: "NO PLAYERS",
                            message: adminService.isAdminMode ? "Tap + to add your first player" : "No players added yet"
                        )
                    } else {
                        // Players list
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(statsService.players) { player in
                                    PlayerManagementRow(
                                        player: player,
                                        careerStats: careerStatsFor(player),
                                        isAdminMode: adminService.isAdminMode,
                                        onTap: {
                                            if let stats = careerStatsFor(player) {
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
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Admin toggle button
                    Button(action: {
                        if adminService.isAdminMode {
                            adminService.logout()
                        } else {
                            showingAdminPIN = true
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: adminService.isAdminMode ? "lock.open.fill" : "lock.fill")
                                .font(.system(size: 14))
                            Text(adminService.isAdminMode ? "ADMIN" : "")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(adminService.isAdminMode ? TronColors.green : TronColors.dimText)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("PLAYERS")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.cyan)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if adminService.isAdminMode {
                        Button(action: { showingAddPlayer = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(TronColors.green)
                                .neonGlow(color: TronColors.green, radius: 5)
                        }
                    }
                }
            }
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
            .alert("DELETE PLAYER", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let player = playerToDelete {
                        deletePlayer(player)
                    }
                }
            } message: {
                Text("Are you sure you want to remove \(playerToDelete?.name ?? "this player")? Their stats will be preserved but they won't appear in active lists.")
            }
            .sheet(item: $selectedCareerStats) { stats in
                PlayerCareerDetailView(stats: stats)
            }
        }
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

// MARK: - Quick Add Bar
struct QuickAddPlayerBar: View {
    let onAdd: () -> Void

    var body: some View {
        Button(action: onAdd) {
            HStack {
                Image(systemName: "plus.circle")
                    .font(.system(size: 18))
                Text("ADD NEW PLAYER")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                Spacer()
            }
            .foregroundColor(TronColors.green)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(TronColors.cardBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(TronColors.green.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
        }
    }
}

// MARK: - Player Management Row
struct PlayerManagementRow: View {
    let player: Player
    let careerStats: CareerStats?
    let isAdminMode: Bool
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Tappable player info area
            Button(action: onTap) {
                HStack(spacing: 12) {
                    // Avatar placeholder
                    ZStack {
                        Circle()
                            .fill(TronColors.surfaceBackground)
                            .frame(width: 44, height: 44)

                        Circle()
                            .stroke(TronColors.cyan.opacity(0.5), lineWidth: 1)
                            .frame(width: 44, height: 44)

                        Text(String(player.name.prefix(1)).uppercased())
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(TronColors.cyan)
                    }

                    // Player info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.name.uppercased())
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(TronColors.primaryText)

                        if let stats = careerStats {
                            Text("\(stats.totalDongs) CAREER DONGS • \(stats.seasonsPlayed) SEASONS")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(TronColors.dimText)
                        }
                    }

                    Spacer()

                    if careerStats != nil {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                            .foregroundColor(TronColors.dimText)
                    }
                }
            }
            .buttonStyle(.plain)

            // Action buttons (only show in admin mode)
            if isAdminMode {
                HStack(spacing: 12) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(TronColors.cyan)
                    }

                    Button(action: onDelete) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(TronColors.orange)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(TronColors.cardBackground)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(TronColors.gridLine.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Admin PIN Entry View
struct AdminPINEntryView: View {
    @EnvironmentObject var adminService: AdminService
    @Environment(\.dismiss) var dismiss
    @State private var pin = ""
    @State private var showError = false

    var body: some View {
        NavigationStack {
            ZStack {
                TronGridBackground()

                VStack(spacing: 24) {
                    // Lock icon
                    ZStack {
                        Circle()
                            .fill(TronColors.cyan.opacity(0.2))
                            .frame(width: 80, height: 80)

                        Image(systemName: "lock.fill")
                            .font(.system(size: 32))
                            .foregroundColor(TronColors.cyan)
                    }
                    .neonGlow(color: TronColors.cyan, radius: 10)

                    Text("ENTER ADMIN PIN")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.cyan)

                    // PIN display
                    HStack(spacing: 12) {
                        ForEach(0..<4) { index in
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(TronColors.cardBackground)
                                    .frame(width: 50, height: 60)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(showError ? TronColors.orange : TronColors.cyan.opacity(0.5), lineWidth: 2)
                                    )

                                if index < pin.count {
                                    Circle()
                                        .fill(TronColors.cyan)
                                        .frame(width: 16, height: 16)
                                        .neonGlow(color: TronColors.cyan, radius: 5)
                                }
                            }
                        }
                    }

                    if showError {
                        Text("INCORRECT PIN")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(TronColors.orange)
                    }

                    // Number pad
                    VStack(spacing: 12) {
                        ForEach(0..<3) { row in
                            HStack(spacing: 12) {
                                ForEach(1...3, id: \.self) { col in
                                    let number = row * 3 + col
                                    PINButton(number: "\(number)") {
                                        addDigit("\(number)")
                                    }
                                }
                            }
                        }
                        HStack(spacing: 12) {
                            // Empty space
                            Color.clear
                                .frame(width: 70, height: 70)

                            PINButton(number: "0") {
                                addDigit("0")
                            }

                            // Delete button
                            Button(action: deleteDigit) {
                                ZStack {
                                    Circle()
                                        .fill(TronColors.cardBackground)
                                        .frame(width: 70, height: 70)

                                    Image(systemName: "delete.left")
                                        .font(.system(size: 24))
                                        .foregroundColor(TronColors.orange)
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.top, 40)
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
struct PINButton: View {
    let number: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(TronColors.cardBackground)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle()
                            .stroke(TronColors.cyan.opacity(0.3), lineWidth: 1)
                    )

                Text(number)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(TronColors.primaryText)
            }
        }
    }
}

#Preview {
    PlayersView()
        .environmentObject(StatsService())
        .environmentObject(AdminService.shared)
}
