//
//  CareerStatsView.swift
//  Dong Country Ledger 5000
//
//  View career statistics across all seasons
//

import SwiftUI

struct CareerStatsView: View {
    @EnvironmentObject var statsService: StatsService
    @State private var selectedCategory: StatCategory = .dongs
    @State private var selectedPlayer: CareerStats?

    var careerStats: [CareerStats] {
        HistoricalData.calculateCareerStats(currentSeasonStats: statsService.yearlyStats)
    }

    enum StatCategory: String, CaseIterable {
        case dongs = "DONGS"
        case doublePlays = "DPs"
        case salamies = "SALAMIS"
        case dongRobs = "ROBS"

        var color: Color {
            switch self {
            case .dongs: return TronColors.cyan
            case .doublePlays: return TronColors.magenta
            case .salamies: return TronColors.green
            case .dongRobs: return Color.purple
            }
        }
    }

    var sortedStats: [CareerStats] {
        switch selectedCategory {
        case .dongs:
            return careerStats.filter { $0.totalDongs > 0 }.sorted { $0.totalDongs > $1.totalDongs }
        case .doublePlays:
            return careerStats.filter { $0.totalDoublePlays > 0 }.sorted { $0.totalDoublePlays > $1.totalDoublePlays }
        case .salamies:
            return careerStats.filter { $0.totalSalamies > 0 }.sorted { $0.totalSalamies > $1.totalSalamies }
        case .dongRobs:
            return careerStats.filter { $0.totalDongRobs > 0 }.sorted { $0.totalDongRobs > $1.totalDongRobs }
        }
    }

    func valueFor(_ stat: CareerStats) -> Int {
        switch selectedCategory {
        case .dongs: return stat.totalDongs
        case .doublePlays: return stat.totalDoublePlays
        case .salamies: return stat.totalSalamies
        case .dongRobs: return stat.totalDongRobs
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                TronGridBackground()

                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 4) {
                        Text("CAREER STATS")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(TronColors.secondaryText)

                        Text("ALL TIME")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(TronColors.cyan)
                            .neonGlow(color: TronColors.cyan, radius: 10)
                    }
                    .padding(.vertical, 16)

                    // Category picker
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

                    // Stats list
                    if sortedStats.isEmpty {
                        VStack {
                            Spacer()
                            Text("NO DATA")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(TronColors.dimText)
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(Array(sortedStats.enumerated()), id: \.element.id) { index, stat in
                                    CareerStatRow(
                                        stats: stat,
                                        value: valueFor(stat),
                                        rank: index + 1,
                                        color: selectedCategory.color
                                    )
                                    .onTapGesture {
                                        selectedPlayer = stat
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("CAREERS")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.cyan)
                }
            }
            .sheet(item: $selectedPlayer) { player in
                PlayerCareerDetailView(stats: player)
            }
        }
    }
}

// MARK: - Career Stat Row
struct CareerStatRow: View {
    let stats: CareerStats
    let value: Int
    let rank: Int
    let color: Color

    var rankColor: Color {
        switch rank {
        case 1: return TronColors.yellow
        case 2: return TronColors.cyan
        case 3: return TronColors.orange
        default: return TronColors.dimText
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("\(rank)")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(rankColor)
                .frame(width: 28)

            // Player info
            VStack(alignment: .leading, spacing: 2) {
                Text(stats.playerName.uppercased())
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(TronColors.primaryText)
                    .lineLimit(1)

                Text("\(stats.seasonsPlayed) SEASONS")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(TronColors.dimText)
            }

            Spacer()

            // Value
            Text("\(value)")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .neonGlow(color: color, radius: rank <= 3 ? 5 : 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 10))
                .foregroundColor(TronColors.dimText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(TronColors.cardBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(rank <= 3 ? rankColor.opacity(0.3) : TronColors.gridLine.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Player Career Detail View
struct PlayerCareerDetailView: View {
    let stats: CareerStats
    @Environment(\.dismiss) var dismiss

    // Get achievements for this player (uses combined career stats already passed in)
    var playerAchievements: PlayerAchievements {
        AchievementsCalculator.calculateAchievements(for: stats.playerName, careerStats: stats)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                TronGridBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        // Player name header
                        Text(stats.playerName.uppercased())
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(TronColors.cyan)
                            .neonGlow(color: TronColors.cyan, radius: 10)
                            .padding(.top, 20)

                        Text("\(stats.seasonsPlayed) SEASONS PLAYED")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(TronColors.secondaryText)

                        // Achievement badges
                        if playerAchievements.hasBadges {
                            VStack(spacing: 8) {
                                Text("ACHIEVEMENTS")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(TronColors.secondaryText)

                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 12) {
                                    ForEach(playerAchievements.badges) { badge in
                                        BadgeDisplayView(badge: badge)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // Stats grid - only dongs, double plays, salamies, dong robberies
                        VStack(spacing: 12) {
                            CareerStatCard(title: "DONGS", value: stats.totalDongs, color: TronColors.cyan)
                            CareerStatCard(title: "DOUBLE PLAYS", value: stats.totalDoublePlays, color: TronColors.magenta)
                            CareerStatCard(title: "SALAMIES", value: stats.totalSalamies, color: TronColors.green)
                            CareerStatCard(title: "DONG ROBBERIES", value: stats.totalDongRobs, color: Color.purple)

                            // YFSLA Championships
                            let champCount = YFSLAChampions.champCount(for: stats.playerName)
                            if champCount > 0 {
                                CareerStatCard(title: "YFSLA CHAMPIONSHIPS", value: champCount, color: TronColors.yellow)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(TronColors.orange)
                }
            }
        }
    }
}

// MARK: - Badge Display View (for BadgeInfo)
struct BadgeDisplayView: View {
    let badge: BadgeInfo

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(badge.color.opacity(0.2))
                    .frame(width: 50, height: 50)

                Circle()
                    .stroke(badge.color, lineWidth: 2)
                    .frame(width: 50, height: 50)

                Image(systemName: badge.icon)
                    .font(.system(size: 20))
                    .foregroundColor(badge.color)

                // Multiplier badge
                if badge.multiplier > 1 {
                    Text("\(badge.multiplier)X")
                        .font(.system(size: 8, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(badge.color)
                        .cornerRadius(4)
                        .offset(x: 18, y: -18)
                }
            }
            .neonGlow(color: badge.color, radius: 5)

            Text(badge.name.uppercased())
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(badge.color)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Career Stat Card
struct CareerStatCard: View {
    let title: String
    let value: Int
    let color: Color

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(TronColors.secondaryText)

            Spacer()

            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(value > 0 ? color : TronColors.dimText)
                .neonGlow(color: value > 0 ? color : .clear, radius: 5)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(TronColors.cardBackground)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    CareerStatsView()
        .environmentObject(StatsService())
}
