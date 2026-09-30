//
//  LeaderboardView.swift
//  Dong Country Ledger 5000
//
//  Season leaderboard (Stickball Rich skin)
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var statsService: StatsService
    @State private var selectedCategory: StatCategory = .dongs  // Default to dongs

    enum StatCategory: String, CaseIterable {
        case dongs = "DONGS"
        case salamies = "SALAMIES"
        case wins = "WINS"
        case drops = "DROPS"
        case doublePlays = "DBL PLY"

        var title: String {
            self == .doublePlays ? "DOUBLE PLAYS" : rawValue
        }

        private var artName: String {
            switch self {
            case .dongs: return "Dongs"
            case .salamies: return "Salamies"
            case .wins: return "Wins"
            case .drops: return "Drops"
            case .doublePlays: return "Double_Plays"
            }
        }

        var selectedImage: String { "SR_Selected_\(artName)" }
        var unselectedImage: String { "SR_Unselected_\(artName)" }

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
            return statsService.yearlyStats.filter { $0.totalDongs > 0 }.sorted { $0.totalDongs > $1.totalDongs }
        case .drops:
            return statsService.yearlyStats.filter { $0.totalDrops > 0 }.sorted { $0.totalDrops > $1.totalDrops }
        case .doublePlays:
            return statsService.yearlyStats.filter { $0.totalDoublePlays > 0 }.sorted { $0.totalDoublePlays > $1.totalDoublePlays }
        case .salamies:
            return statsService.yearlyStats.filter { $0.totalSalamies > 0 }.sorted { $0.totalSalamies > $1.totalSalamies }
        case .wins:
            return statsService.yearlyStats.filter { $0.totalWins > 0 }.sorted { $0.totalWins > $1.totalWins }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                SRBackground()

                ScrollView {
                    VStack(spacing: 10) {
                        SRHeader(banner: "SR_Season_9_Leaders")

                        // Category buttons (scrolls sideways; art is too wide to fit all five)
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 0) {
                                    ForEach(StatCategory.allCases, id: \.self) { category in
                                        let isSelected = selectedCategory == category
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.15)) {
                                                selectedCategory = category
                                                proxy.scrollTo(category, anchor: .center)
                                            }
                                        }) {
                                            Image(isSelected ? category.selectedImage : category.unselectedImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(height: isSelected ? 52 : 40)
                                        }
                                        .buttonStyle(.plain)
                                        .id(category)
                                        .accessibilityLabel(category.title)
                                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                                    }
                                }
                                .frame(height: 56)
                                .padding(.horizontal, 8)
                            }
                        }

                        // Column labels
                        HStack {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 12))
                                .srGoldText()
                            Text("PLAYER")
                                .font(SRFont.display(15))
                                .srGoldText()
                                .padding(.leading, 40)
                            Spacer()
                            Text(selectedCategory.title)
                                .font(SRFont.display(15))
                                .srGoldText()
                        }
                        .padding(.horizontal, 28)

                        // Leaderboard
                        if sortedStats.isEmpty {
                            SRArtPlate("SR_Player_Row_Empty") { _ in
                                VStack(spacing: 4) {
                                    Text("NO STATS YET")
                                        .font(SRFont.display(20))
                                        .foregroundColor(SRColors.text)
                                    Text("Enter weekly stats to see the leaders")
                                        .font(SRFont.mono(11))
                                        .foregroundColor(SRColors.gold)
                                }
                            }
                            .padding(.horizontal, 12)
                        } else {
                            // Negative spacing absorbs the transparent glow padding in the row art
                            LazyVStack(spacing: -22) {
                                ForEach(Array(sortedStats.enumerated()), id: \.element.id) { index, stats in
                                    LeaderboardRow(
                                        stats: stats,
                                        rank: index + 1,
                                        category: selectedCategory
                                    )
                                }
                            }
                            .padding(.horizontal, 12)
                        }

                        SRFooterLogo()
                    }
                    .padding(.bottom, 12)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
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
        SRRankRow(rank: rank, name: stats.playerName, value: highlightedValue)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(rank). \(stats.playerName), \(highlightedValue) \(category.title.lowercased())")
    }
}

#Preview {
    LeaderboardView()
        .environmentObject(StatsService())
}
