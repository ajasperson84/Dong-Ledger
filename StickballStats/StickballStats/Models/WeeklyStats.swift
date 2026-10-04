//
//  WeeklyStats.swift
//  StickballStats
//

import Foundation
import FirebaseFirestore

struct WeeklyStats: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var playerId: String
    var playerName: String  // Denormalized for easier display
    var weekNumber: Int
    var year: Int
    var season: Int?  // nil for entries saved before seasons were tagged (Season 8)
    var dongs: Int
    var drops: Int
    var doublePlays: Int
    var salamies: Int
    var wins: Int
    var createdAt: Date
    var updatedAt: Date

    init(playerId: String, playerName: String, weekNumber: Int, year: Int) {
        self.playerId = playerId
        self.playerName = playerName
        self.weekNumber = weekNumber
        self.year = year
        self.season = SeasonSchedule.shared.seasonNumber
        self.dongs = 0
        self.drops = 0
        self.doublePlays = 0
        self.salamies = 0
        self.wins = 0
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    /// Season this entry belongs to; untagged entries are from Season 8
    var seasonNumber: Int {
        season ?? 8
    }

    // Helper to get week identifier
    var weekIdentifier: String {
        return "\(year)-W\(String(format: "%02d", weekNumber))"
    }

    /// True once anything has been recorded for this player this week
    var hasAnyStats: Bool {
        dongs + drops + doublePlays + salamies + wins > 0
    }

    // Total points (for leaderboard sorting)
    var totalPoints: Int {
        return dongs + salamies + wins - drops - doublePlays
    }
}

// Aggregated stats for a player across a year
struct YearlyStats: Identifiable, Hashable {
    var id: String { playerId }
    var playerId: String
    var playerName: String
    var year: Int
    var totalDongs: Int
    var totalDrops: Int
    var totalDoublePlays: Int
    var totalSalamies: Int
    var totalWins: Int
    var gamesPlayed: Int

    init(playerId: String, playerName: String, year: Int) {
        self.playerId = playerId
        self.playerName = playerName
        self.year = year
        self.totalDongs = 0
        self.totalDrops = 0
        self.totalDoublePlays = 0
        self.totalSalamies = 0
        self.totalWins = 0
        self.gamesPlayed = 0
    }

    mutating func addWeeklyStats(_ stats: WeeklyStats) {
        totalDongs += stats.dongs
        totalDrops += stats.drops
        totalDoublePlays += stats.doublePlays
        totalSalamies += stats.salamies
        totalWins += stats.wins
        gamesPlayed += 1
    }

    var totalPoints: Int {
        return totalDongs + totalSalamies + totalWins - totalDrops - totalDoublePlays
    }

    // Averages per week
    var avgDongs: Double {
        gamesPlayed > 0 ? Double(totalDongs) / Double(gamesPlayed) : 0
    }

    var avgDrops: Double {
        gamesPlayed > 0 ? Double(totalDrops) / Double(gamesPlayed) : 0
    }
}
