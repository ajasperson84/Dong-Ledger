//
//  NameShortener.swift
//  Dong Country Ledger 5000
//
//  Custom player name abbreviations for stat line display
//  Max 5 characters
//

import Foundation

extension String {
    /// Custom name abbreviations for stickball players
    private static let nameMap: [String: String] = [
        "Salary": "$al",
        "The Deal": "Deal",
        "Dong Robber": "Dong",
        "Baby Boi": "Baby",
        "Cojones": "CoJo",
        "Cuidado": "Cui",
        "Candyman": "Candy",
        "Flash Dance": "Flash",
        "Slacker": "Slack",
        "Goat Cheese": "Goat",
        "Party Platter": "Party",
        "Uncle Kimmy": "Dublé",
        "Extra Credit": "Extra",
        "Barely Bonds": "Bare",
        "Rookie Derek": "RookD",
        "Rookie Coop": "RookC",
        "Surgeon": "Surge",
        "Katfish": "Kat",
        "Hot Tub": "Tub",
        "Rookie Aiden": "RookA",
        "Lunch Money": "Lunch",
        "White Noize": "Noize",
        "The Swarm": "Swarm",
        "Boogie Joe": "Boog"
    ]

    /// Returns the custom short name for stat display
    /// Falls back to first 5 characters if not in the map
    var shortName: String {
        let trimmed = self.trimmingCharacters(in: .whitespaces)

        // Look up in custom map (case-insensitive)
        for (fullName, shortName) in String.nameMap {
            if trimmed.lowercased() == fullName.lowercased() {
                return shortName
            }
        }

        // Fallback: return first 5 characters
        return String(trimmed.prefix(5))
    }
}
