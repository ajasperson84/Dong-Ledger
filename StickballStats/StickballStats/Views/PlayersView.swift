//
//  PlayersView.swift
//  StickballStats
//
//  Player management view
//

import SwiftUI

struct PlayersView: View {
    @EnvironmentObject var statsService: StatsService
    @State private var showingAddPlayer = false
    @State private var selectedPlayer: Player?
    @State private var showingDeleteConfirmation = false
    @State private var playerToDelete: Player?

    var body: some View {
        NavigationStack {
            ZStack {
                TronGridBackground()

                VStack(spacing: 0) {
                    // Quick add bar
                    QuickAddPlayerBar(onAdd: { showingAddPlayer = true })
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                    if statsService.players.isEmpty {
                        EmptyStateView(
                            icon: "person.3",
                            title: "NO PLAYERS",
                            message: "Tap + to add your first player"
                        )
                    } else {
                        // Players list
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(statsService.players) { player in
                                    PlayerManagementRow(
                                        player: player,
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
                ToolbarItem(placement: .principal) {
                    Text("PLAYERS")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.cyan)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddPlayer = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(TronColors.green)
                            .neonGlow(color: TronColors.green, radius: 5)
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
                    .stroke(TronColors.green.opacity(0.3), lineWidth: 1)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
        }
    }
}

// MARK: - Player Management Row
struct PlayerManagementRow: View {
    let player: Player
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Avatar placeholder
            ZStack {
                Circle()
                    .fill(TronColors.surfaceBackground)
                    .frame(width: 44, height: 44)

                Circle()
                    .stroke(TronColors.cyan.opacity(0.5), lineWidth: 1)
                    .frame(width: 44, height: 44)

                if let number = player.jerseyNumber {
                    Text("#\(number)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.cyan)
                } else {
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.cyan)
                }
            }

            // Player info
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name.uppercased())
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(TronColors.primaryText)

                if let team = player.teamName, !team.isEmpty {
                    Text(team.uppercased())
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(TronColors.dimText)
                }
            }

            Spacer()

            // Action buttons
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

#Preview {
    PlayersView()
        .environmentObject(StatsService())
}
