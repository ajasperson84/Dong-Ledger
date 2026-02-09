//
//  Achievements.swift
//  Dong Country Ledger 5000
//
//  Achievement badges, Player of the Week, and Season Awards
//

import Foundation
import SwiftUI

// MARK: - Achievement Badge Types
enum AchievementBadge: String, CaseIterable, Identifiable {
    case firstSalami = "First Salami"
    case centuryClub100 = "Century Club"
    case centuryClub200 = "Double Century"
    case centuryClub300 = "Triple Century"
    case centuryClub400 = "Quad Century"
    case centuryClub500 = "500 Club"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .firstSalami: return "star.fill"
        case .centuryClub100: return "100.circle.fill"
        case .centuryClub200: return "trophy.fill"
        case .centuryClub300: return "crown.fill"
        case .centuryClub400: return "flame.fill"
        case .centuryClub500: return "bolt.fill"
        }
    }

    var color: Color {
        switch self {
        case .firstSalami: return TronColors.green
        case .centuryClub100: return TronColors.cyan
        case .centuryClub200: return TronColors.yellow
        case .centuryClub300: return TronColors.orange
        case .centuryClub400: return TronColors.magenta
        case .centuryClub500: return Color.purple
        }
    }

    var description: String {
        switch self {
        case .firstSalami: return "Hit your first career salami"
        case .centuryClub100: return "100 career dongs"
        case .centuryClub200: return "200 career dongs"
        case .centuryClub300: return "300 career dongs"
        case .centuryClub400: return "400 career dongs"
        case .centuryClub500: return "500 career dongs"
        }
    }
}

// MARK: - Player Achievement Record
struct PlayerAchievements: Identifiable {
    var id: String { playerName }
    let playerName: String
    var badges: [AchievementBadge] = []
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

    // Best New Baby - best rookie (first season player with best performance)
    var bestNewBaby: String?
    var bestNewBabyDongs: Int = 0
}

// MARK: - Achievements Calculator
struct AchievementsCalculator {

    // MARK: - Calculate Player Achievements
    static func calculateAchievements(for playerName: String, careerStats: CareerStats) -> PlayerAchievements {
        var achievements = PlayerAchievements(playerName: playerName)

        // First Salami
        if careerStats.totalSalamies >= 1 {
            achievements.badges.append(.firstSalami)
        }

        // Century Club badges - only show the highest milestone achieved
        if careerStats.totalDongs >= 500 {
            achievements.badges.append(.centuryClub500)
        } else if careerStats.totalDongs >= 400 {
            achievements.badges.append(.centuryClub400)
        } else if careerStats.totalDongs >= 300 {
            achievements.badges.append(.centuryClub300)
        } else if careerStats.totalDongs >= 200 {
            achievements.badges.append(.centuryClub200)
        } else if careerStats.totalDongs >= 100 {
            achievements.badges.append(.centuryClub100)
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

        // Find Best New Baby (rookie with best performance)
        var bestRookieDongs = 0
        for player in season.playerStats {
            let canonical = PlayerAliases.canonicalName(for: player.playerName)
            // Check if this is their first season
            if !previousPlayers.contains(canonical) {
                if player.dongs > bestRookieDongs {
                    bestRookieDongs = player.dongs
                    awards.bestNewBaby = player.playerName
                    awards.bestNewBabyDongs = player.dongs
                }
            }
        }

        return awards
    }

    // MARK: - Get All Season Awards
    static func getAllSeasonAwards() -> [SeasonAwards] {
        var allAwards: [SeasonAwards] = []
        let seasons = HistoricalData.seasons

        for (index, season) in seasons.enumerated() {
            let previousSeasons = Array(seasons.prefix(index))
            let awards = calculateSeasonAwards(for: season, previousSeasons: previousSeasons)
            allAwards.append(awards)
        }

        return allAwards
    }

    // MARK: - Get All Player Achievements
    static func getAllPlayerAchievements() -> [PlayerAchievements] {
        let careerStats = HistoricalData.calculateCareerStats()
        var achievementsList: [PlayerAchievements] = []

        for stats in careerStats {
            let achievements = calculateAchievements(
                for: stats.playerName,
                careerStats: stats
            )
            achievementsList.append(achievements)
        }

        return achievementsList.filter { !$0.badges.isEmpty }
    }
}
