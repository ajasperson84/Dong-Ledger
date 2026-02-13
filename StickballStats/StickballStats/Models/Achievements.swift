//
//  Achievements.swift
//  Dong Country Ledger 5000
//
//  Achievement badges, Player of the Week, and Season Awards
//

import Foundation
import SwiftUI

// MARK: - Badge Display Info
struct BadgeInfo: Identifiable {
    var id: String { name }
    let name: String
    let icon: String
    let color: Color
    var multiplier: Int = 0 // For awards won multiple times (2X, 3X, etc.)
}

// MARK: - Salami Club Tier
enum SalamiTier {
    case none
    case base      // 1+ salamies
    case bronze    // 10+ salamies
    case silver    // 20+ salamies
    case gold      // 30+ salamies
    case platinum  // 40+ salamies

    var color: Color {
        switch self {
        case .none: return .clear
        case .base: return TronColors.green
        case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.8)
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .platinum: return Color(red: 0.9, green: 0.9, blue: 0.95)
        }
    }

    var name: String {
        switch self {
        case .none: return ""
        case .base: return "Salami Club"
        case .bronze: return "Salami Club"
        case .silver: return "Salami Club"
        case .gold: return "Salami Club"
        case .platinum: return "Salami Club"
        }
    }

    static func tier(for salamies: Int) -> SalamiTier {
        if salamies >= 40 { return .platinum }
        if salamies >= 30 { return .gold }
        if salamies >= 20 { return .silver }
        if salamies >= 10 { return .bronze }
        if salamies >= 1 { return .base }
        return .none
    }
}

// MARK: - Century Club Tier
enum CenturyTier {
    case none
    case base100   // 100+ dongs - cyan/teal
    case bronze200 // 200+ dongs
    case silver300 // 300+ dongs
    case gold400   // 400+ dongs
    case platinum500 // 500+ dongs

    var color: Color {
        switch self {
        case .none: return .clear
        case .base100: return TronColors.cyan
        case .bronze200: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .silver300: return Color(red: 0.75, green: 0.75, blue: 0.8)
        case .gold400: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .platinum500: return Color(red: 0.9, green: 0.9, blue: 0.95)
        }
    }

    var name: String {
        switch self {
        case .none: return ""
        case .base100: return "Century Club"
        case .bronze200: return "200 Club"
        case .silver300: return "300 Club"
        case .gold400: return "400 Club"
        case .platinum500: return "500 Club"
        }
    }

    static func tier(for dongs: Int) -> CenturyTier {
        if dongs >= 500 { return .platinum500 }
        if dongs >= 400 { return .gold400 }
        if dongs >= 300 { return .silver300 }
        if dongs >= 200 { return .bronze200 }
        if dongs >= 100 { return .base100 }
        return .none
    }
}

// MARK: - Player Achievement Record
struct PlayerAchievements: Identifiable {
    var id: String { playerName }
    let playerName: String

    // Tiered badges
    var salamiTier: SalamiTier = .none
    var centuryTier: CenturyTier = .none

    // Award badges with counts
    var mvpCount: Int = 0
    var dongKingCount: Int = 0
    var rookieOfYearCount: Int = 0
    var yfslaChampCount: Int = 0
    var hasCoattails: Bool = false

    // Get all badges as displayable info
    var badges: [BadgeInfo] {
        var result: [BadgeInfo] = []

        // Salami Club
        if salamiTier != .none {
            result.append(BadgeInfo(
                name: salamiTier.name,
                icon: "leaf.fill", // Closest to salami/sausage shape
                color: salamiTier.color
            ))
        }

        // Century Club
        if centuryTier != .none {
            result.append(BadgeInfo(
                name: centuryTier.name,
                icon: "tennisball.fill",
                color: centuryTier.color
            ))
        }

        // MVP
        if mvpCount > 0 {
            result.append(BadgeInfo(
                name: "MVP",
                icon: "star.fill",
                color: TronColors.yellow,
                multiplier: mvpCount
            ))
        }

        // Dong King
        if dongKingCount > 0 {
            result.append(BadgeInfo(
                name: "Dong King",
                icon: "crown.fill",
                color: TronColors.cyan,
                multiplier: dongKingCount
            ))
        }

        // Rookie of the Year
        if rookieOfYearCount > 0 {
            result.append(BadgeInfo(
                name: "Rookie of the Year",
                icon: "figure.child",
                color: TronColors.green,
                multiplier: rookieOfYearCount
            ))
        }

        // Coattails
        if hasCoattails {
            result.append(BadgeInfo(
                name: "Coattails",
                icon: "tshirt.fill",
                color: TronColors.magenta
            ))
        }

        return result
    }

    var hasBadges: Bool {
        return salamiTier != .none || centuryTier != .none ||
               mvpCount > 0 || dongKingCount > 0 || rookieOfYearCount > 0 ||
               hasCoattails
    }
}

// MARK: - Player of the Week
struct PlayerOfTheWeek: Identifiable {
    var id: String { "\(seasonNumber)-\(weekNumber)" }
    let seasonNumber: Int
    let weekNumber: Int
    let playerName: String
    let score: Double
    let dongs: Int
    let doublePlays: Int
    let wins: Int
    let drops: Int
}

// MARK: - Season Awards
struct SeasonAwards: Identifiable {
    var id: Int { seasonNumber }
    let seasonNumber: Int
    let seasonName: String

    // Dong King - most dongs
    var dongKing: String?
    var dongKingTotal: Int = 0

    // MVP - most dongs + wins combined
    var mvp: String?
    var mvpDongs: Int = 0
    var mvpWins: Int = 0

    // Rookie of the Year (formerly Best New Baby)
    var rookieOfYear: String?
    var rookieOfYearDongs: Int = 0
}

// MARK: - YFSLA Champions Data
struct YFSLAChampions {
    // Players with YFSLA Championship wins (number in parentheses)
    static let champions: [String: Int] = [
        "Dong Robber": 2,
        "Party Platter": 1,
        "Dong Quixote": 3,
        "Flash Dance": 1,
        "Lunch Money": 2,
        "Baby Boi": 3,
        "The Deal": 4,
        "Cuidado": 2,
        "Candyman": 3,
        "Katfish": 2,
        "Cojones": 1,
        "Hot Tub": 3,
        "Dr. Big Dick": 2
    ]

    static func champCount(for playerName: String) -> Int {
        return champions[playerName] ?? 0
    }
}

// MARK: - Coattails Players
struct CoattailsPlayers {
    static let players: Set<String> = [
        "Party Platter",
        "Dong Robber",
        "Baby Boi",
        "Cuidado",
        "The Deal"
    ]

    static func hasCoattails(_ playerName: String) -> Bool {
        return players.contains(playerName)
    }
}

// MARK: - Achievements Calculator
struct AchievementsCalculator {

    // MARK: - Calculate Player Achievements
    static func calculateAchievements(for playerName: String, careerStats: CareerStats) -> PlayerAchievements {
        var achievements = PlayerAchievements(playerName: playerName)

        // Salami Club tier
        achievements.salamiTier = SalamiTier.tier(for: careerStats.totalSalamies)

        // Century Club tier
        achievements.centuryTier = CenturyTier.tier(for: careerStats.totalDongs)

        // YFSLA Champ count
        achievements.yfslaChampCount = YFSLAChampions.champCount(for: playerName)

        // Coattails
        achievements.hasCoattails = CoattailsPlayers.hasCoattails(playerName)

        // Count MVP, Dong King, and Rookie of Year awards from historical seasons
        let allAwards = getAllSeasonAwards()
        for award in allAwards {
            if let mvp = award.mvp, PlayerAliases.canonicalName(for: mvp) == playerName {
                achievements.mvpCount += 1
            }
            if let dk = award.dongKing, PlayerAliases.canonicalName(for: dk) == playerName {
                achievements.dongKingCount += 1
            }
            if let roy = award.rookieOfYear, PlayerAliases.canonicalName(for: roy) == playerName {
                achievements.rookieOfYearCount += 1
            }
        }

        return achievements
    }

    // MARK: - Calculate Player of the Week Score
    /// Weighted score: dongs (1.0), double plays (0.5), wins (0.3), drops (-0.2)
    static func calculateWeeklyScore(dongs: Int, doublePlays: Int, wins: Int, drops: Int) -> Double {
        return Double(dongs) * 1.0 + Double(doublePlays) * 0.5 + Double(wins) * 0.3 - Double(drops) * 0.2
    }

    // MARK: - Calculate Season Awards
    static func calculateSeasonAwards(for season: HistoricalSeasonStats, previousSeasons: [HistoricalSeasonStats]) -> SeasonAwards {
        var awards = SeasonAwards(seasonNumber: season.seasonNumber, seasonName: season.seasonName)

        // Get all players who played in previous seasons
        var previousPlayers = Set<String>()
        for prevSeason in previousSeasons {
            for player in prevSeason.playerStats {
                let canonical = PlayerAliases.canonicalName(for: player.playerName)
                previousPlayers.insert(canonical)
            }
        }

        // Find Dong King (most dongs)
        if let topDonger = season.playerStats.max(by: { $0.dongs < $1.dongs }) {
            awards.dongKing = topDonger.playerName
            awards.dongKingTotal = topDonger.dongs
        }

        // Find MVP (most dongs + wins)
        var bestMVPScore = 0
        for player in season.playerStats {
            let score = player.dongs + player.wins
            if score > bestMVPScore {
                bestMVPScore = score
                awards.mvp = player.playerName
                awards.mvpDongs = player.dongs
                awards.mvpWins = player.wins
            }
        }

        // Find Rookie of the Year (rookie with best performance)
        var bestRookieDongs = 0
        for player in season.playerStats {
            let canonical = PlayerAliases.canonicalName(for: player.playerName)
            // Check if this is their first season
            if !previousPlayers.contains(canonical) {
                if player.dongs > bestRookieDongs {
                    bestRookieDongs = player.dongs
                    awards.rookieOfYear = player.playerName
                    awards.rookieOfYearDongs = player.dongs
                }
            }
        }

        return awards
    }

    // MARK: - Get All Season Awards
    static func getAllSeasonAwards() -> [SeasonAwards] {
        var allAwards: [SeasonAwards] = []
        // Filter out season 8 since it's the current season
        let seasons = HistoricalData.seasons.filter { $0.seasonNumber < 8 }

        for (index, season) in seasons.enumerated() {
            let previousSeasons = Array(seasons.prefix(index))
            let awards = calculateSeasonAwards(for: season, previousSeasons: previousSeasons)
            allAwards.append(awards)
        }

        return allAwards
    }

    // MARK: - Get All Player Achievements
    static func getAllPlayerAchievements(currentSeasonStats: [YearlyStats] = []) -> [PlayerAchievements] {
        let careerStats = HistoricalData.calculateCareerStats(currentSeasonStats: currentSeasonStats)
        var achievementsList: [PlayerAchievements] = []

        for stats in careerStats {
            let achievements = calculateAchievements(
                for: stats.playerName,
                careerStats: stats
            )
            achievementsList.append(achievements)
        }

        return achievementsList.filter { $0.hasBadges }
    }
}
