//
//  PlayerRow.swift
//  StickballStats
//
//  Display row for a player with their stats
//

import SwiftUI

struct PlayerRow: View {
    let player: Player
    let stats: WeeklyStats?
    let rank: Int?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Rank (if provided)
                if let rank = rank {
                    Text("#\(rank)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(rankColor(rank))
                        .frame(width: 35)
                        .neonGlow(color: rankColor(rank), radius: rank <= 3 ? 5 : 0)
                }

                // Player info
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name.uppercased())
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.primaryText)

                    if let team = player.teamName {
                        Text(team)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(TronColors.dimText)
                    }
                }

                Spacer()

                // Stats badges
                if let stats = stats {
                    HStack(spacing: 8) {
                        StatBadge(title: "DONG", value: stats.dongs, color: TronColors.cyan)
                        StatBadge(title: "DROP", value: stats.drops, color: TronColors.orange)
                        StatBadge(title: "DP", value: stats.doublePlays, color: TronColors.magenta)
                        StatBadge(title: "SALA", value: stats.salamies, color: TronColors.green)
                        StatBadge(title: "WIN", value: stats.wins, color: TronColors.yellow)
                    }
                } else {
                    Text("NO STATS")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(TronColors.dimText)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(TronColors.cyan.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(TronColors.cardBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(TronColors.cyan.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return TronColors.yellow
        case 2: return TronColors.cyan
        case 3: return TronColors.orange
        default: return TronColors.dimText
        }
    }
}

// MARK: - Yearly Stats Row
struct YearlyStatsRow: View {
    let stats: YearlyStats
    let rank: Int

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("#\(rank)")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(rankColor(rank))
                .frame(width: 40)
                .neonGlow(color: rankColor(rank), radius: rank <= 3 ? 5 : 0)

            // Player name
            VStack(alignment: .leading, spacing: 2) {
                Text(stats.playerName.uppercased())
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(TronColors.primaryText)

                Text("\(stats.gamesPlayed) WEEKS")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(TronColors.dimText)
            }

            Spacer()

            // Total stats
            HStack(spacing: 6) {
                StatBadge(title: "DONG", value: stats.totalDongs, color: TronColors.cyan)
                StatBadge(title: "DROP", value: stats.totalDrops, color: TronColors.orange)
                StatBadge(title: "DP", value: stats.totalDoublePlays, color: TronColors.magenta)
                StatBadge(title: "SALA", value: stats.totalSalamies, color: TronColors.green)
                StatBadge(title: "WIN", value: stats.totalWins, color: TronColors.yellow)
            }

            // Total points
            VStack(spacing: 2) {
                Text("\(stats.totalPoints)")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(stats.totalPoints >= 0 ? TronColors.cyan : TronColors.orange)
                    .neonGlow(color: stats.totalPoints >= 0 ? TronColors.cyan : TronColors.orange, radius: 5)

                Text("PTS")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(TronColors.dimText)
            }
            .frame(width: 50)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(TronColors.cardBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(rankColor(rank).opacity(rank <= 3 ? 0.5 : 0.2), lineWidth: 1)
        )
        .neonGlow(color: rankColor(rank), radius: rank <= 3 ? 3 : 0)
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return TronColors.yellow
        case 2: return TronColors.cyan
        case 3: return TronColors.orange
        default: return TronColors.gridLine
        }
    }
}

#Preview {
    ZStack {
        TronGridBackground()
        VStack(spacing: 12) {
            PlayerRow(
                player: Player(name: "John Doe", jerseyNumber: 42, teamName: "Neon Knights"),
                stats: WeeklyStats(playerId: "1", playerName: "John Doe", weekNumber: 10, year: 2024),
                rank: 1,
                onTap: {}
            )

            PlayerRow(
                player: Player(name: "Jane Smith", teamName: "Grid Runners"),
                stats: nil,
                rank: 2,
                onTap: {}
            )
        }
        .padding()
    }
}
