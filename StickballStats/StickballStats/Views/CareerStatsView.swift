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
        ZStack {
            SRBackground()

            ScrollView {
                VStack(spacing: 10) {
                    HStack {
                        Button(action: { dismiss() }) { Color.clear }
                            .buttonStyle(.srImage("Done_Button"))
                            .frame(width: 104, height: 48)
                            .accessibilityLabel("Done")
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)

                    // Name and seasons on the profile plaque
                    SRArtPlate("SR_Profile_Header_Plaque_Blank") { size in
                        ZStack {
                            Text(stats.playerName.uppercased())
                                .font(SRFont.slab(size.height * 0.15))
                                .foregroundColor(SRColors.text)
                                .shadow(color: .black, radius: 1, x: 0, y: 1)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .frame(width: size.width * 0.74)
                                .position(x: size.width * 0.5, y: size.height * 0.545)
                            Text("\(stats.seasonsPlayed) SEASONS PLAYED")
                                .font(SRFont.mono(size.height * 0.07))
                                .foregroundColor(SRColors.gold)
                                .position(x: size.width * 0.5, y: size.height * 0.835)
                        }
                    }
                    .padding(.horizontal, 10)

                    // Achievement badges
                    if playerAchievements.hasBadges {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(playerAchievements.badges) { badge in
                                BadgeDisplayView(badge: badge)
                            }
                        }
                        .padding(.horizontal, 12)
                    }

                    // Career totals
                    VStack(spacing: 2) {
                        ProfileStatRow(title: "DONGS", value: stats.totalDongs)
                        ProfileStatRow(title: "DOUBLE PLAYS", value: stats.totalDoublePlays)
                        ProfileStatRow(title: "SALAMIES", value: stats.totalSalamies)
                        ProfileStatRow(title: "DONG ROBBERIES", value: stats.totalDongRobs)

                        // YFSLA Championships
                        let champCount = YFSLAChampions.champCount(for: stats.playerName)
                        if champCount > 0 {
                            ProfileStatRow(title: "YFSLA CHAMPIONSHIPS", value: champCount)
                        }
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Profile Stat Row
/// Stat label in the long plate and the diamond total in the end box
struct ProfileStatRow: View {
    let title: String
    let value: Int

    var body: some View {
        SRArtPlate("SR_Profile_Stat_Row_Blank") { size in
            ZStack {
                Text(title)
                    .font(SRFont.display(size.height * 0.26))
                    .srGoldText()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(width: size.width * 0.62, alignment: .leading)
                    .position(x: size.width * 0.39, y: size.height * 0.52)
                DiamondNumber(value: value, height: size.height * 0.48)
                    .position(x: size.width * 0.865, y: size.height * 0.52)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title.lowercased()): \(value)")
    }
}

// MARK: - Badge Display View (for BadgeInfo)
struct BadgeDisplayView: View {
    let badge: BadgeInfo

    /// Achievement medallion art for badges that have it
    private var artName: String? {
        switch badge.name {
        case "Salami Club": return "SR_Achievement_Salami_Club"
        case "Century Club": return "SR_Achievement_100_Club"
        case "200 Club": return "SR_Achievement_200_Club"
        case "300 Club": return "SR_Achievement_300_Club"
        case "400 Club": return "SR_Achievement_400_Club"
        case "Coattails": return "SR_Achievement_Coattails"
        case "Galactics": return "SR_Achievement_Galactics"
        case "Wide Open": return "SR_Achievement_Wide_Open"
        case "MVP": return "SR_Achievement_MVP"
        case "Dong King": return "SR_Achievement_Dong_King"
        case "Rookie of the Year": return "SR_Achievement_Rookie_Of_The_Year"
        default: return nil
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                if let artName {
                    Image(artName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 86)
                } else {
                    ZStack {
                        Circle()
                            .fill(RadialGradient(colors: [badge.color.opacity(0.5), .black], center: .center, startRadius: 2, endRadius: 34))
                        Circle()
                            .stroke(SRColors.goldGradient, lineWidth: 4)
                        Image(systemName: badge.icon)
                            .font(.system(size: 26))
                            .srGoldText()
                    }
                    .frame(width: 70, height: 70)
                    .frame(height: 86)
                }

                // Multiplier badge
                if badge.multiplier > 1 {
                    Text("\(badge.multiplier)X")
                        .font(SRFont.display(12))
                        .foregroundColor(.black)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(SRColors.goldGradient)
                        .cornerRadius(4)
                }
            }

            // Art already carries the badge title
            if artName == nil {
                Text(badge.name.uppercased())
                    .font(SRFont.display(11))
                    .srGoldText()
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(badge.multiplier > 1 ? "\(badge.name), \(badge.multiplier) times" : badge.name)
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
