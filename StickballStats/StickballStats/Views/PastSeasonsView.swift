//
//  PastSeasonsView.swift
//  Dong Country Ledger 5000
//
//  Browse historical season totals
//

import SwiftUI

struct PastSeasonsView: View {
    @State private var selectedSeason: HistoricalSeasonStats?

    var body: some View {
        NavigationStack {
            ZStack {
                TronGridBackground()

                ScrollView {
                    VStack(spacing: 12) {
                        // Header
                        Text("PAST SEASONS")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(TronColors.cyan)
                            .neonGlow(color: TronColors.cyan, radius: 8)
                            .padding(.top, 16)

                        // Season cards
                        ForEach(HistoricalData.seasons.reversed()) { season in
                            SeasonCard(season: season)
                                .onTapGesture {
                                    selectedSeason = season
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedSeason) { season in
                SeasonDetailView(season: season)
            }
        }
    }
}

// MARK: - Season Card
struct SeasonCard: View {
    let season: HistoricalSeasonStats

    var topDonger: HistoricalPlayerSeasonStats? {
        season.playerStats.max(by: { $0.dongs < $1.dongs })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SEASON \(season.seasonNumber)")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.cyan)

                    Text(season.seasonName.uppercased())
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(TronColors.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(TronColors.dimText)
            }

            if let top = topDonger {
                HStack {
                    Text("DONG LEADER:")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(TronColors.dimText)

                    Text(top.playerName.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.green)

                    Text("(\(top.dongs))")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.green)
                }
            }
        }
        .padding(16)
        .background(TronColors.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(TronColors.gridLine.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Season Detail View
struct SeasonDetailView: View {
    let season: HistoricalSeasonStats
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: StatCategory = .dongs

    enum StatCategory: String, CaseIterable {
        case dongs = "DONGS"
        case drops = "DROPS"
        case doublePlays = "DPs"
        case salamies = "SALAMIS"
        case wins = "WINS"
        case dongRobs = "ROBS"

        var color: Color {
            switch self {
            case .dongs: return TronColors.cyan
            case .drops: return TronColors.orange
            case .doublePlays: return TronColors.magenta
            case .salamies: return TronColors.green
            case .wins: return TronColors.yellow
            case .dongRobs: return Color.purple
            }
        }
    }

    var sortedStats: [HistoricalPlayerSeasonStats] {
        switch selectedCategory {
        case .dongs:
            return season.playerStats.filter { $0.dongs > 0 }.sorted { $0.dongs > $1.dongs }
        case .drops:
            return season.playerStats.filter { $0.drops > 0 }.sorted { $0.drops > $1.drops }
        case .doublePlays:
            return season.playerStats.filter { $0.doublePlays > 0 }.sorted { $0.doublePlays > $1.doublePlays }
        case .salamies:
            return season.playerStats.filter { $0.salamies > 0 }.sorted { $0.salamies > $1.salamies }
        case .wins:
            return season.playerStats.filter { $0.wins > 0 }.sorted { $0.wins > $1.wins }
        case .dongRobs:
            return season.playerStats.filter { $0.dongRobs > 0 }.sorted { $0.dongRobs > $1.dongRobs }
        }
    }

    func valueFor(_ stat: HistoricalPlayerSeasonStats) -> Int {
        switch selectedCategory {
        case .dongs: return stat.dongs
        case .drops: return stat.drops
        case .doublePlays: return stat.doublePlays
        case .salamies: return stat.salamies
        case .wins: return stat.wins
        case .dongRobs: return stat.dongRobs
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                TronGridBackground()

                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 4) {
                        Text("SEASON \(season.seasonNumber)")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(TronColors.cyan)
                            .neonGlow(color: TronColors.cyan, radius: 10)

                        Text(season.seasonName.uppercased())
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(TronColors.secondaryText)
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
                                    HistoricalStatRow(
                                        playerName: stat.playerName,
                                        value: valueFor(stat),
                                        rank: index + 1,
                                        color: selectedCategory.color
                                    )
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

// MARK: - Historical Stat Row
struct HistoricalStatRow: View {
    let playerName: String
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

            // Player name
            Text(playerName.uppercased())
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(TronColors.primaryText)
                .lineLimit(1)

            Spacer()

            // Value
            Text("\(value)")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .neonGlow(color: color, radius: rank <= 3 ? 5 : 0)
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

#Preview {
    PastSeasonsView()
}
