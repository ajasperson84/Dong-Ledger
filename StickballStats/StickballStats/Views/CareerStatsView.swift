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

    let careerStats = HistoricalData.calculateCareerStats()

    enum StatCategory: String, CaseIterable {
        case dongs = "DONGS"
        case drops = "DROPS"
        case doublePlays = "DPs"
        case salamies = "SALAMIS"
        case wins = "WINS"
        case dongRobs = "ROBS"
        case seasons = "SEASONS"

        var color: Color {
            switch self {
            case .dongs: return TronColors.cyan
            case .drops: return TronColors.orange
            case .doublePlays: return TronColors.magenta
            case .salamies: return TronColors.green
            case .wins: return TronColors.yellow
            case .dongRobs: return Color.purple
            case .seasons: return TronColors.cyan
            }
        }
    }

    var sortedStats: [CareerStats] {
        switch selectedCategory {
        case .dongs:
            return careerStats.filter { $0.totalDongs > 0 }.sorted { $0.totalDongs > $1.totalDongs }
        case .drops:
            return careerStats.filter { $0.totalDrops > 0 }.sorted { $0.totalDrops > $1.totalDrops }
        case .doublePlays:
            return careerStats.filter { $0.totalDoublePlays > 0 }.sorted { $0.totalDoublePlays > $1.totalDoublePlays }
        case .salamies:
            return careerStats.filter { $0.totalSalamies > 0 }.sorted { $0.totalSalamies > $1.totalSalamies }
        case .wins:
            return careerStats.filter { $0.totalWins > 0 }.sorted { $0.totalWins > $1.totalWins }
        case .dongRobs:
            return careerStats.filter { $0.totalDongRobs > 0 }.sorted { $0.totalDongRobs > $1.totalDongRobs }
        case .seasons:
            return careerStats.sorted { $0.seasonsPlayed > $1.seasonsPlayed }
        }
    }

    func valueFor(_ stat: CareerStats) -> Int {
        switch selectedCategory {
        case .dongs: return stat.totalDongs
        case .drops: return stat.totalDrops
        case .doublePlays: return stat.totalDoublePlays
        case .salamies: return stat.totalSalamies
        case .wins: return stat.totalWins
        case .dongRobs: return stat.totalDongRobs
        case .seasons: return stat.seasonsPlayed
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

                        // Stats grid
                        VStack(spacing: 12) {
                            CareerStatCard(title: "DONGS", value: stats.totalDongs, color: TronColors.cyan)
                            CareerStatCard(title: "DROPS", value: stats.totalDrops, color: TronColors.orange)
                            CareerStatCard(title: "DOUBLE PLAYS", value: stats.totalDoublePlays, color: TronColors.magenta)
                            CareerStatCard(title: "SALAMIES", value: stats.totalSalamies, color: TronColors.green)
                            CareerStatCard(title: "WINS", value: stats.totalWins, color: TronColors.yellow)
                            CareerStatCard(title: "DONG ROBBERIES", value: stats.totalDongRobs, color: Color.purple)
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
