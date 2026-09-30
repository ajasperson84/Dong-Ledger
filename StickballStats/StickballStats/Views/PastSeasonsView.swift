//
//  PastSeasonsView.swift
//  Dong Country Ledger 5000
//
//  Browse historical season totals (Stickball Rich skin)
//

import SwiftUI

struct PastSeasonsView: View {
    @State private var selectedSeason: HistoricalSeasonStats?

    var body: some View {
        NavigationStack {
            ZStack {
                SRBackground()

                ScrollView {
                    VStack(spacing: 6) {
                        // PAST SEASONS banner on its own, larger, in place of the title lockup
                        Image("SR_Past_Seasons_Banner")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .containerRelativeFrame(.horizontal) { width, _ in width * 0.98 }
                            .padding(.top, 4)
                            .padding(.bottom, 6)
                            .accessibilityLabel("Past Seasons")

                        // Most recent season first (current season is excluded).
                        // Negative spacing absorbs the transparent glow padding in the row art.
                        VStack(spacing: -30) {
                            ForEach(HistoricalData.pastSeasons.reversed()) { season in
                                Button(action: { selectedSeason = season }) {
                                    SeasonCard(season: season)
                                }
                                .buttonStyle(SeasonRowButtonStyle())
                            }
                        }
                        .padding(.horizontal, 8)

                        SRFooterLogo()
                    }
                    .padding(.bottom, 12)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selectedSeason) { season in
                SeasonDetailView(season: season)
            }
        }
    }
}

// MARK: - Season Row Button Style
/// Archive row art that lights up while pressed
struct SeasonRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Image(configuration.isPressed ? "SR_Past_Season_Row_Selected" : "SR_Past_Season_Row_Unselected")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .overlay(configuration.label)
    }
}

// MARK: - Season Card
/// Text laid over the archive row: medallion number, title, subtitle and dong leader
struct SeasonCard: View {
    let season: HistoricalSeasonStats

    var topDonger: HistoricalPlayerSeasonStats? {
        season.playerStats.max(by: { $0.dongs < $1.dongs })
    }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack(alignment: .topLeading) {
                DiamondNumber(value: season.seasonNumber, height: size.height * 0.44)
                    .position(x: size.width * 0.121, y: size.height * 0.505)

                VStack(alignment: .leading, spacing: 1) {
                    Text("SEASON \(season.seasonNumber)")
                        .font(SRFont.slab(size.height * 0.165))
                        .foregroundStyle(
                            LinearGradient(colors: [.white, Color(white: 0.75), .white], startPoint: .top, endPoint: .bottom)
                        )
                    Text(season.seasonName.uppercased())
                        .font(SRFont.mono(size.height * 0.095))
                        .foregroundColor(SRColors.text)
                    if let top = topDonger {
                        HStack(spacing: 4) {
                            Text("DONG LEADER:")
                                .foregroundColor(SRColors.gold)
                            Text("\(top.playerName.uppercased()) (\(top.dongs))")
                                .foregroundColor(SRColors.pink)
                        }
                        .font(SRFont.mono(size.height * 0.095))
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(width: size.width * 0.60, alignment: .leading)
                .offset(x: size.width * 0.22, y: size.height * 0.285)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Season Detail View
struct SeasonDetailView: View {
    let season: HistoricalSeasonStats
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: StatCategory = .dongs
    @State private var showingAwards = false

    // Get season awards
    var seasonAwards: SeasonAwards {
        let allAwards = AchievementsCalculator.getAllSeasonAwards()
        return allAwards.first { $0.seasonNumber == season.seasonNumber } ?? SeasonAwards(seasonNumber: season.seasonNumber, seasonName: season.seasonName)
    }

    enum StatCategory: String, CaseIterable {
        case dongs = "DONGS"
        case salamies = "SALAMIS"
        case wins = "WINS"
        case drops = "DROPS"
        case doublePlays = "DPs"
        case dongRobs = "ROBS"

        var title: String {
            switch self {
            case .dongs: return "DONGS"
            case .salamies: return "SALAMIES"
            case .wins: return "WINS"
            case .drops: return "DROPS"
            case .doublePlays: return "DOUBLE PLAYS"
            case .dongRobs: return "DONG ROBS"
            }
        }

        /// Labeled category art; Dong Robs has no art so it uses the blank plate with text
        @ViewBuilder
        func buttonArt(isSelected: Bool) -> some View {
            let state = isSelected ? "Selected" : "Unselected"
            switch self {
            case .dongRobs:
                Image("SR_\(state)_Blank")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay(
                        Text("ROBS")
                            .font(SRFont.slab(isSelected ? 20 : 16))
                            .foregroundColor(SRColors.text)
                    )
            default:
                Image("SR_\(state)_\(artName)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }

        private var artName: String {
            switch self {
            case .dongs: return "Dongs"
            case .salamies: return "Salamies"
            case .wins: return "Wins"
            case .drops: return "Drops"
            case .doublePlays, .dongRobs: return "Double_Plays"
            }
        }

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

                    // Season title plaque
                    SRArtPlate("SR_Historic_Season_Header_Blank") { size in
                        ZStack {
                            Text("SEASON \(season.seasonNumber)")
                                .font(SRFont.slab(size.height * 0.20))
                                .foregroundColor(SRColors.text)
                                .shadow(color: .black, radius: 1, x: 0, y: 1)
                                .position(x: size.width * 0.5, y: size.height * 0.44)
                            Text(season.seasonName.uppercased())
                                .font(SRFont.display(size.height * 0.11))
                                .srGoldText()
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .frame(width: size.width * 0.6)
                                .position(x: size.width * 0.5, y: size.height * 0.825)
                        }
                    }
                    .padding(.horizontal, 10)

                    Button(action: { showingAwards = true }) { Color.clear }
                        .buttonStyle(.srImage("Season_Awards_Button"))
                        .padding(.horizontal, 48)
                        .accessibilityLabel("Season awards")

                    // Category buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(StatCategory.allCases, id: \.self) { category in
                                let isSelected = selectedCategory == category
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        selectedCategory = category
                                    }
                                }) {
                                    category.buttonArt(isSelected: isSelected)
                                        .frame(height: isSelected ? 52 : 40)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(category.title)
                                .accessibilityAddTraits(isSelected ? .isSelected : [])
                            }
                        }
                        .frame(height: 56)
                        .padding(.horizontal, 8)
                    }

                    // Stats list
                    if sortedStats.isEmpty {
                        Text("NO DATA")
                            .font(SRFont.display(18))
                            .foregroundColor(SRColors.gold)
                            .padding(.top, 24)
                    } else {
                        LazyVStack(spacing: -22) {
                            ForEach(Array(sortedStats.enumerated()), id: \.element.id) { index, stat in
                                SRRankRow(rank: index + 1, name: stat.playerName, value: valueFor(stat))
                                    .accessibilityElement(children: .ignore)
                                    .accessibilityLabel("\(index + 1). \(stat.playerName), \(valueFor(stat))")
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showingAwards) {
            SeasonAwardsView(awards: seasonAwards)
        }
    }
}

// MARK: - Season Awards View
struct SeasonAwardsView: View {
    let awards: SeasonAwards
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            TronGridBackground()

            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Button(action: { dismiss() }) { Color.clear }
                            .buttonStyle(.srImage("Done_Button"))
                            .frame(width: 104, height: 48)
                            .accessibilityLabel("Done")
                        Spacer()
                    }

                    VStack(spacing: 2) {
                        Text("SEASON \(awards.seasonNumber)")
                            .font(SRFont.display(16))
                            .srGoldText()
                        Text("AWARDS")
                            .font(SRFont.slab(34))
                            .foregroundColor(SRColors.text)
                    }

                    if let dongKing = awards.dongKing {
                        AwardCard(
                            badge: "SR_Achievement_Dong_King",
                            playerName: dongKing,
                            stat: "\(awards.dongKingTotal) DONGS"
                        )
                    }

                    if let mvp = awards.mvp {
                        AwardCard(
                            badge: "SR_Achievement_MVP",
                            playerName: mvp,
                            stat: "\(awards.mvpDongs) DONGS + \(awards.mvpWins) WINS"
                        )
                    }

                    if let rookie = awards.rookieOfYear {
                        AwardCard(
                            badge: "SR_Achievement_Rookie_Of_The_Year",
                            playerName: rookie,
                            stat: "\(awards.rookieOfYearDongs) DONGS"
                        )
                    }

                    if awards.dongKing == nil && awards.mvp == nil && awards.rookieOfYear == nil {
                        Text("NO AWARDS DATA")
                            .font(SRFont.display(16))
                            .foregroundColor(SRColors.gold)
                            .padding(.top, 40)
                    }
                }
                .padding(16)
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Award Card
/// Achievement medallion art with the winner and their numbers
struct AwardCard: View {
    let badge: String
    let playerName: String
    let stat: String

    var body: some View {
        HStack(spacing: 14) {
            Image(badge)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 96, height: 96)

            VStack(alignment: .leading, spacing: 4) {
                Text(playerName.uppercased())
                    .font(SRFont.display(22))
                    .foregroundColor(SRColors.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(stat)
                    .font(SRFont.mono(12))
                    .foregroundColor(SRColors.gold)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .srPlate(glow: SRColors.purple)
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
