//
//  LeaderboardView.swift
//  Dong Country Ledger 5000
//
//  Season leaderboard and statistics
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var statsService: StatsService
    @State private var selectedCategory: StatCategory = .dongs  // Default to dongs

    enum StatCategory: String, CaseIterable {
        case dongs = "DONGS"
        case drops = "DROPS"
        case doublePlays = "DBL PLY"
        case salamies = "SALAMIES"
        case wins = "WINS"

        var color: Color {
            switch self {
            case .dongs: return TronColors.cyan
            case .drops: return TronColors.orange
            case .doublePlays: return TronColors.magenta
            case .salamies: return TronColors.green
            case .wins: return TronColors.yellow
            }
        }
    }

    var sortedStats: [YearlyStats] {
        switch selectedCategory {
        case .dongs:
            return statsService.yearlyStats.sorted { $0.totalDongs > $1.totalDongs }
        case .drops:
            return statsService.yearlyStats.sorted { $0.totalDrops < $1.totalDrops } // Lower is better
        case .doublePlays:
            return statsService.yearlyStats.sorted { $0.totalDoublePlays > $1.totalDoublePlays } // Most first
        case .salamies:
            return statsService.yearlyStats.sorted { $0.totalSalamies > $1.totalSalamies }
        case .wins:
            return statsService.yearlyStats.sorted { $0.totalWins > $1.totalWins }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                TronGridBackground()

                VStack(spacing: 0) {
                    // Season header
                    VStack(spacing: 4) {
                        Text("SEASON STANDINGS")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(TronColors.secondaryText)

                        Text("DONG COUNTRY")
                            .font(.system(size: 28, weight: .black, design: .monospaced))
                            .foregroundColor(TronColors.cyan)
                            .neonGlow(color: TronColors.cyan, radius: 10)
                    }
                    .padding(.vertical, 16)

                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(StatCategory.allCases, id: \.self) { category in
                                CategoryPill(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category,
                                    color: category.color
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedCategory = category
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 12)

                    // Leaderboard
                    if sortedStats.isEmpty {
                        EmptyStateView(
                            icon: "chart.bar.xaxis",
                            title: "NO DATA",
                            message: "Enter weekly stats to see the leaderboard"
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(Array(sortedStats.enumerated()), id: \.element.id) { index, stats in
                                    LeaderboardRow(
                                        stats: stats,
                                        rank: index + 1,
                                        category: selectedCategory
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("LEADERBOARD")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.cyan)
                }
            }
        }
    }
}

// MARK: - Category Pill
struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(isSelected ? TronColors.darkBackground : color)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? color : TronColors.cardBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(isSelected ? 0 : 0.5), lineWidth: 1)
                )
        }
        .neonGlow(color: color, radius: isSelected ? 5 : 0)
    }
}

// MARK: - Leaderboard Row
struct LeaderboardRow: View {
    let stats: YearlyStats
    let rank: Int
    let category: LeaderboardView.StatCategory

    var highlightedValue: Int {
        switch category {
        case .dongs: return stats.totalDongs
        case .drops: return stats.totalDrops
        case .doublePlays: return stats.totalDoublePlays
        case .salamies: return stats.totalSalamies
        case .wins: return stats.totalWins
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Rank badge
            ZStack {
                if rank <= 3 {
                    Circle()
                        .fill(rankColor.opacity(0.2))
                        .frame(width: 36, height: 36)

                    Circle()
                        .stroke(rankColor, lineWidth: 2)
                        .frame(width: 36, height: 36)
                        .neonGlow(color: rankColor, radius: 5)
                }

                Text("\(rank)")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(rankColor)
            }
            .frame(width: 40)

            // Player name
            VStack(alignment: .leading, spacing: 2) {
                Text(stats.playerName.uppercased())
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(TronColors.primaryText)
                    .lineLimit(1)

                Text("\(stats.gamesPlayed) WEEKS PLAYED")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(TronColors.dimText)
            }

            Spacer()

            // Highlighted stat
            VStack(spacing: 2) {
                Text("\(highlightedValue)")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(category.color)
                    .neonGlow(color: category.color, radius: 8)

                Text(category.rawValue)
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundColor(category.color.opacity(0.7))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(TronColors.cardBackground)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(rank <= 3 ? rankColor.opacity(0.4) : TronColors.gridLine.opacity(0.3), lineWidth: 1)
        )
        .neonGlow(color: rankColor, radius: rank == 1 ? 5 : 0)
    }

    var rankColor: Color {
        switch rank {
        case 1: return TronColors.yellow
        case 2: return TronColors.cyan
        case 3: return TronColors.orange
        default: return TronColors.dimText
        }
    }
}

#Preview {
    LeaderboardView()
        .environmentObject(StatsService())
}
