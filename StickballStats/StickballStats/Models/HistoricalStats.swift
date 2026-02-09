//
//  HistoricalStats.swift
//  Dong Country Ledger 5000
//
//  Historical season statistics and career stats
//

import Foundation

// MARK: - Player Name Aliases
struct PlayerAliases {
    /// Maps all known aliases to canonical player names
    static let aliases: [String: String] = [
        // Current roster
        "salary": "Salary",
        "sal": "Salary",
        "$al": "Salary",

        "the deal": "The Deal",
        "deal": "The Deal",
        "dishpan": "The Deal",
        "dishpan deal": "The Deal",
        "dom the deal": "The Deal",

        "dong robber": "Dong Robber",
        "donger": "Dong Robber",
        "dong": "Dong Robber",
        "dong mattingly": "Dong Robber",
        "dong tbh": "Dong Robber",
        "dong the bounty hunter": "Dong Robber",
        "robber": "Dong Robber",
        "dtbh": "Dong Robber",

        "baby boi": "Baby Boi",
        "baby": "Baby Boi",

        "cojones": "Cojones",
        "cajones": "Cojones",
        "cojo": "Cojones",

        "cuidado": "Cuidado",
        "cui": "Cuidado",
        "cuidadokake": "Cuidado",
        "cuiadado": "Cuidado",
        "cuiadadokake": "Cuidado",
        "drukake": "Cuidado",

        "candyman": "Candyman",
        "candy": "Candyman",

        "flash dance": "Flash Dance",
        "flash": "Flash Dance",
        "flashdance": "Flash Dance",

        "slacker": "Slacker",
        "slack": "Slacker",
        "rookie jeff": "Slacker",

        "goat cheese": "Goat Cheese",
        "goat": "Goat Cheese",

        "party platter": "Party Platter",
        "party": "Party Platter",
        "platter": "Party Platter",

        "uncle kimmy": "Uncle Kimmy",
        "kimmy": "Uncle Kimmy",
        "duble": "Uncle Kimmy",
        "dublé": "Uncle Kimmy",
        "kimmy duble": "Uncle Kimmy",
        "dongblé": "Uncle Kimmy",

        "extra credit": "Extra Credit",
        "extra": "Extra Credit",

        "barely bonds": "Barely Bonds",
        "bare": "Barely Bonds",
        "barley bonds": "Barely Bonds",
        "barely": "Barely Bonds",

        "rookie derek": "Rookie Derek",
        "rookd": "Rookie Derek",
        "derek": "Rookie Derek",

        "rookie coop": "Rookie Coop",
        "rookc": "Rookie Coop",
        "coop": "Rookie Coop",

        "surgeon": "Surgeon",
        "surge": "Surgeon",
        "the surgeon": "Surgeon",

        "katfish": "Katfish",
        "kat": "Katfish",

        "hot tub": "Hot Tub",
        "tub": "Hot Tub",

        "rookie aiden": "Rookie Aiden",
        "rooka": "Rookie Aiden",
        "aiden": "Rookie Aiden",
        "rookie aidan": "Rookie Aiden",

        "lunch money": "Lunch Money",
        "lunch": "Lunch Money",
        "lunch box": "Lunch Money",
        "lil jerk": "Lunch Money",

        "white noize": "White Noize",
        "noize": "White Noize",
        "white noise": "White Noize",
        "white": "White Noize",

        "the swarm": "The Swarm",
        "swarm": "The Swarm",

        "boogie joe": "Boogie Joe",
        "boog": "Boogie Joe",
        "boogie": "Boogie Joe",
        "boogs": "Boogie Joe",
        "fuckin boogie joe": "Boogie Joe",
        "fbj": "Boogie Joe",
        "boogie joe the grinder": "Boogie Joe",
        "boogie jabroni": "Boogie Joe",

        // Historical players
        "dr. big dick": "Dr. Big Dick",
        "bdmd": "Dr. Big Dick",
        "big dick": "Dr. Big Dick",
        "dr. bd": "Dr. Big Dick",
        "dr big dick": "Dr. Big Dick",
        "big dick md": "Dr. Big Dick",
        "dr shwantz": "Dr. Big Dick",
        "dr schwantz": "Dr. Big Dick",
        "doc cock": "Dr. Big Dick",

        "fart dolphin": "Fart Cop",
        "fart cop": "Fart Cop",

        "jeffrey bomber": "Jeffrey Bomber",
        "bomber": "Jeffrey Bomber",

        "rookie dave": "Rookie Dave",
        "dave": "Rookie Dave",

        "big whoop": "Big Whoop",
        "whoop": "Big Whoop",

        "silky": "Silky",
        "silk": "Silky",

        "summer camp": "Summer Camp",
        "summer": "Summer Camp",
        "bushwhacker": "Summer Camp",

        "two step": "Two Step",
        "2 step": "Two Step",
        "2-step": "Two Step",
        "laser": "Two Step",

        "rookie gus": "Rookie Gus",
        "gus": "Rookie Gus",

        "rookie otto": "Rookie Otto",
        "otto": "Rookie Otto",

        "rookie alex": "Rookie Alex",
        "alex": "Rookie Alex",

        "rookie reece": "Rookie Reece",
        "reece": "Rookie Reece",

        "dong quixote": "Dong Quixote",
        "dq": "Dong Quixote",
        "quixote": "Dong Quixote",
        "dong quiote": "Dong Quixote",

        "kdaddy": "Kdaddy",

        "jeff": "JEFF",

        "golf shotz": "Golf Shotz",
        "shotz": "Golf Shotz",

        "deadliest catch": "Deadliest Catch",
        "deadliest": "Deadliest Catch",

        "pantera rosa": "Pantera Rosa",
        "pantera": "Pantera Rosa",

        "cutz": "Cutz",

        "ez-up": "Ez-Up",
        "ez up": "Ez-Up",
        "ez": "Ez-Up",

        "puppet master": "Puppet Master",
        "puppet": "Puppet Master",

        "starf": "Starf",
        "starfish": "Starf",

        "the american dream": "American Dream",
        "american dream": "American Dream",

        "motorboat": "Motorboat",
        "bingo": "Motorboat",
        "motorboat bingo": "Motorboat",

        "lothario": "Lothario",

        "the game": "The Game",

        "raw dog": "Raw Dog",
        "rawdogg": "Raw Dog",
        "rawdog": "Raw Dog",

        "big sexy": "Big Sexy",

        "rookie ahmet": "Rookie Ahmet",
        "ahmet": "Rookie Ahmet",

        "rookie ben": "Rookie Ben",
        "ben": "Rookie Ben",

        "spider": "Spider",

        "tv dad": "TV Dad",

        "the rooster": "The Rooster",
        "rooster": "The Rooster",

        "solo shot": "Solo Shot",

        "daisy cutter": "Daisy Cutter",
        "daisy": "Daisy Cutter",

        "rookie johnny": "Rookie Johnny",
        "johnny": "Rookie Johnny",

        "rookie corn": "Rookie Corn",
        "corn": "Rookie Corn",

        "country club": "Country Club",

        "natural": "Natural",
        "natch": "Natural",

        "hot dog": "Hot Dog",

        "rookie danger": "Rookie Danger",
        "danger": "Rookie Danger",

        "rookie han": "Rookie Han",
        "han": "Rookie Han",

        "grom": "Grom",

        "rookie jackson": "Rookie Jackson",
        "jackson": "Rookie Jackson",

        "rookie adam": "Rookie Adam",
        "adam": "Rookie Adam",

        "brunch": "Brunch",

        "jugalo": "Jugalo",

        "rookie brett": "Rookie Brett",
        "brett": "Rookie Brett",

        "rookie praveen": "Rookie Praveen",
        "praveen": "Rookie Praveen",

        "dan the fister": "Dan The Fister",
        "fister": "Dan The Fister",

        "8ball": "8Ball",

        "dallas buyers club": "Dallas Buyers Club",

        "keanu": "Keanu",

        "big trip": "Big Trip",
        "trip": "Big Trip",

        "trees": "Trees",

        "rookie mike": "Rookie Mike",
        "mike": "Rookie Mike",

        "rookie kyle": "Rookie Kyle",
        "kyle": "Rookie Kyle",

        "brother big dick": "Brother Big Dick",

        "rookie drew": "Rookie Drew",
        "drew": "Rookie Drew",

        "rookie graham": "Rookie Graham",
        "graham": "Rookie Graham",

        "rookie andrew": "Rookie Andrew",
        "andrew": "Rookie Andrew",

        "rookie mensch": "Rookie Mensch",
        "mensch": "Rookie Mensch",

        "rookie dan": "Rookie Dan",
        "dan": "Rookie Dan",

        "kousin koepke": "Kousin Koepke",

        "backdoor": "Backdoor",

        "rookie eric": "Rookie Eric",
        "eric": "Rookie Eric",

        "rookie bill": "Rookie Bill",
        "bill": "Rookie Bill",

        "eli": "Eli",

        "rookie taku": "Rookie Taku",
        "taku": "Rookie Taku",

        "rookie sheesha": "Rookie Sheesha",
        "sheesha": "Rookie Sheesha",

        "rookie nuri": "Rookie Nuri",
        "nuri": "Rookie Nuri",

        "cuijano": "Cuijano",

        "rosé canseco": "Rosé Canseco",
        "canseco": "Rosé Canseco",

        "web": "Web",

        "cricket": "Cricket"
    ]

    /// Get canonical player name from any alias
    static func canonicalName(for name: String) -> String {
        let lowercased = name.lowercased().trimmingCharacters(in: .whitespaces)
        return aliases[lowercased] ?? name
    }
}

// MARK: - Historical Season Stats
struct HistoricalSeasonStats: Identifiable, Codable {
    var id: Int { seasonNumber }
    let seasonNumber: Int
    let seasonName: String
    let playerStats: [HistoricalPlayerSeasonStats]
}

struct HistoricalPlayerSeasonStats: Identifiable, Codable {
    var id: String { playerName }
    let playerName: String
    let dongs: Int
    let drops: Int
    let doublePlays: Int
    let salamies: Int
    let wins: Int
    let dongRobs: Int
}

// MARK: - Career Stats
struct CareerStats: Identifiable {
    var id: String { playerName }
    let playerName: String
    var totalDongs: Int = 0
    var totalDrops: Int = 0
    var totalDoublePlays: Int = 0
    var totalSalamies: Int = 0
    var totalWins: Int = 0
    var totalDongRobs: Int = 0
    var seasonsPlayed: Int = 0

    mutating func add(season: HistoricalPlayerSeasonStats) {
        totalDongs += season.dongs
        totalDrops += season.drops
        totalDoublePlays += season.doublePlays
        totalSalamies += season.salamies
        totalWins += season.wins
        totalDongRobs += season.dongRobs
        seasonsPlayed += 1
    }
}

// MARK: - Historical Data
struct HistoricalData {
    static let seasons: [HistoricalSeasonStats] = [
        // Season 2: Regular Season 2 '20
        HistoricalSeasonStats(
            seasonNumber: 2,
            seasonName: "Regular Season 2 '20",
            playerStats: [
                HistoricalPlayerSeasonStats(playerName: "Dr. Big Dick", dongs: 62, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "The Deal", dongs: 46, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Golf Shotz", dongs: 44, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Dong Robber", dongs: 28, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 8),
                HistoricalPlayerSeasonStats(playerName: "Salary", dongs: 26, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Party Platter", dongs: 17, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 4),
                HistoricalPlayerSeasonStats(playerName: "Baby Boi", dongs: 16, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "American Dream", dongs: 16, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Starf", dongs: 15, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "JEFF", dongs: 15, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Silky", dongs: 15, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Boogie Joe", dongs: 14, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Cutz", dongs: 13, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Katfish", dongs: 10, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Ez-Up", dongs: 7, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Hot Tub", dongs: 6, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "The Game", dongs: 6, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Puppet Master", dongs: 5, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Lothario", dongs: 4, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Pantera Rosa", dongs: 3, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Deadliest Catch", dongs: 3, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Big Whoop", dongs: 3, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Raw Dog", dongs: 3, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Surgeon", dongs: 2, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Motorboat", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Country Club", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Kousin Koepke", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Backdoor", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0)
            ]
        ),

        // Season 3: The Re3erection
        HistoricalSeasonStats(
            seasonNumber: 3,
            seasonName: "The Re3erection",
            playerStats: [
                HistoricalPlayerSeasonStats(playerName: "Dong Robber", dongs: 87, drops: 0, doublePlays: 0, salamies: 5, wins: 4, dongRobs: 14),
                HistoricalPlayerSeasonStats(playerName: "Hot Tub", dongs: 62, drops: 0, doublePlays: 0, salamies: 3, wins: 5, dongRobs: 5),
                HistoricalPlayerSeasonStats(playerName: "Salary", dongs: 52, drops: 0, doublePlays: 0, salamies: 1, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "The Deal", dongs: 51, drops: 0, doublePlays: 1, salamies: 1, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Dr. Big Dick", dongs: 45, drops: 0, doublePlays: 0, salamies: 3, wins: 3, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Candyman", dongs: 35, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 1),
                HistoricalPlayerSeasonStats(playerName: "Party Platter", dongs: 28, drops: 0, doublePlays: 0, salamies: 2, wins: 3, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Boogie Joe", dongs: 26, drops: 0, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Kdaddy", dongs: 25, drops: 0, doublePlays: 0, salamies: 1, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Lunch Money", dongs: 21, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Surgeon", dongs: 17, drops: 0, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Cojones", dongs: 13, drops: 0, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 2),
                HistoricalPlayerSeasonStats(playerName: "Deadliest Catch", dongs: 9, drops: 0, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Ahmet", dongs: 9, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Summer Camp", dongs: 9, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Silky", dongs: 8, drops: 0, doublePlays: 0, salamies: 1, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Cutz", dongs: 8, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "JEFF", dongs: 7, drops: 0, doublePlays: 0, salamies: 1, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Puppet Master", dongs: 6, drops: 0, doublePlays: 0, salamies: 2, wins: 0, dongRobs: 1),
                HistoricalPlayerSeasonStats(playerName: "Big Sexy", dongs: 4, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 1),
                HistoricalPlayerSeasonStats(playerName: "Golf Shotz", dongs: 4, drops: 0, doublePlays: 1, salamies: 1, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "American Dream", dongs: 4, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Dong Quixote", dongs: 4, drops: 0, doublePlays: 0, salamies: 0, wins: 3, dongRobs: 2),
                HistoricalPlayerSeasonStats(playerName: "Starf", dongs: 3, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Pantera Rosa", dongs: 3, drops: 0, doublePlays: 0, salamies: 0, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Motorboat", dongs: 2, drops: 0, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "The Swarm", dongs: 2, drops: 0, doublePlays: 0, salamies: 0, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Ez-Up", dongs: 2, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Taku", dongs: 2, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Lothario", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Baby Boi", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 2, dongRobs: 2),
                HistoricalPlayerSeasonStats(playerName: "Country Club", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Katfish", dongs: 0, drops: 0, doublePlays: 0, salamies: 1, wins: 0, dongRobs: 0)
            ]
        ),

        // Season 4: Pillars of Success
        HistoricalSeasonStats(
            seasonNumber: 4,
            seasonName: "Pillars of Success",
            playerStats: [
                HistoricalPlayerSeasonStats(playerName: "Cuidado", dongs: 50, drops: 0, doublePlays: 0, salamies: 1, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Lunch Money", dongs: 37, drops: 0, doublePlays: 0, salamies: 2, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Candyman", dongs: 37, drops: 0, doublePlays: 1, salamies: 3, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "The Deal", dongs: 30, drops: 0, doublePlays: 0, salamies: 4, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Dr. Big Dick", dongs: 29, drops: 0, doublePlays: 0, salamies: 1, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Boogie Joe", dongs: 26, drops: 0, doublePlays: 1, salamies: 1, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Party Platter", dongs: 25, drops: 0, doublePlays: 1, salamies: 0, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Salary", dongs: 18, drops: 0, doublePlays: 0, salamies: 1, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Dong Robber", dongs: 16, drops: 0, doublePlays: 0, salamies: 1, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Two Step", dongs: 15, drops: 0, doublePlays: 0, salamies: 1, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Hot Tub", dongs: 13, drops: 0, doublePlays: 0, salamies: 1, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Silky", dongs: 9, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Surgeon", dongs: 9, drops: 0, doublePlays: 1, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Cojones", dongs: 4, drops: 0, doublePlays: 1, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Dong Quixote", dongs: 4, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Big Whoop", dongs: 4, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "The Rooster", dongs: 3, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "TV Dad", dongs: 3, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Katfish", dongs: 3, drops: 0, doublePlays: 0, salamies: 0, wins: 3, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Spider", dongs: 3, drops: 0, doublePlays: 0, salamies: 1, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Corn", dongs: 3, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "JEFF", dongs: 2, drops: 0, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Solo Shot", dongs: 2, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Uncle Kimmy", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Motorboat", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Deadliest Catch", dongs: 1, drops: 0, doublePlays: 1, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Starf", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Ez-Up", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Daisy Cutter", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Summer Camp", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0)
            ]
        ),

        // Season 5: Star Power
        HistoricalSeasonStats(
            seasonNumber: 5,
            seasonName: "Star Power",
            playerStats: [
                HistoricalPlayerSeasonStats(playerName: "Cuidado", dongs: 77, drops: 0, doublePlays: 0, salamies: 4, wins: 0, dongRobs: 1),
                HistoricalPlayerSeasonStats(playerName: "Dong Robber", dongs: 63, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 5),
                HistoricalPlayerSeasonStats(playerName: "Candyman", dongs: 55, drops: 0, doublePlays: 1, salamies: 0, wins: 0, dongRobs: 1),
                HistoricalPlayerSeasonStats(playerName: "Dr. Big Dick", dongs: 22, drops: 0, doublePlays: 1, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Cojones", dongs: 22, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Salary", dongs: 20, drops: 0, doublePlays: 1, salamies: 0, wins: 0, dongRobs: 1),
                HistoricalPlayerSeasonStats(playerName: "Party Platter", dongs: 19, drops: 0, doublePlays: 0, salamies: 1, wins: 0, dongRobs: 5),
                HistoricalPlayerSeasonStats(playerName: "The Deal", dongs: 15, drops: 0, doublePlays: 2, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Boogie Joe", dongs: 14, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Lunch Money", dongs: 12, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Hot Tub", dongs: 11, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 2),
                HistoricalPlayerSeasonStats(playerName: "Rookie Jeff", dongs: 9, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Silky", dongs: 8, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 1),
                HistoricalPlayerSeasonStats(playerName: "Surgeon", dongs: 8, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Two Step", dongs: 6, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Dong Quixote", dongs: 4, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Big Whoop", dongs: 3, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Kyle", dongs: 2, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Big Trip", dongs: 2, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Trees", dongs: 2, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Mike", dongs: 2, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Katfish", dongs: 1, drops: 0, doublePlays: 2, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Daisy Cutter", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Brother Big Dick", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0)
            ]
        ),

        // Season 6: What's Under The Dirt?
        HistoricalSeasonStats(
            seasonNumber: 6,
            seasonName: "What's Under The Dirt?",
            playerStats: [
                HistoricalPlayerSeasonStats(playerName: "Cuidado", dongs: 130, drops: 0, doublePlays: 1, salamies: 6, wins: 16, dongRobs: 3),
                HistoricalPlayerSeasonStats(playerName: "Dong Robber", dongs: 87, drops: 0, doublePlays: 0, salamies: 6, wins: 8, dongRobs: 10),
                HistoricalPlayerSeasonStats(playerName: "Candyman", dongs: 79, drops: 0, doublePlays: 3, salamies: 2, wins: 8, dongRobs: 1),
                HistoricalPlayerSeasonStats(playerName: "Flash Dance", dongs: 62, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Party Platter", dongs: 59, drops: 0, doublePlays: 3, salamies: 3, wins: 8, dongRobs: 3),
                HistoricalPlayerSeasonStats(playerName: "Goat Cheese", dongs: 42, drops: 0, doublePlays: 0, salamies: 2, wins: 10, dongRobs: 8),
                HistoricalPlayerSeasonStats(playerName: "The Deal", dongs: 38, drops: 0, doublePlays: 0, salamies: 3, wins: 7, dongRobs: 2),
                HistoricalPlayerSeasonStats(playerName: "Extra Credit", dongs: 32, drops: 0, doublePlays: 0, salamies: 0, wins: 5, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Salary", dongs: 28, drops: 0, doublePlays: 0, salamies: 1, wins: 6, dongRobs: 1),
                HistoricalPlayerSeasonStats(playerName: "Boogie Joe", dongs: 24, drops: 0, doublePlays: 4, salamies: 2, wins: 4, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Lunch Money", dongs: 23, drops: 0, doublePlays: 0, salamies: 1, wins: 7, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Hot Tub", dongs: 20, drops: 0, doublePlays: 2, salamies: 0, wins: 4, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Cojones", dongs: 16, drops: 0, doublePlays: 0, salamies: 1, wins: 3, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Silky", dongs: 13, drops: 0, doublePlays: 0, salamies: 0, wins: 2, dongRobs: 1),
                HistoricalPlayerSeasonStats(playerName: "Surgeon", dongs: 12, drops: 0, doublePlays: 0, salamies: 1, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Barely Bonds", dongs: 9, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 1),
                HistoricalPlayerSeasonStats(playerName: "Two Step", dongs: 8, drops: 0, doublePlays: 0, salamies: 0, wins: 3, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Doc Cock", dongs: 8, drops: 0, doublePlays: 2, salamies: 1, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Big Whoop", dongs: 7, drops: 0, doublePlays: 0, salamies: 1, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Slacker", dongs: 5, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Ez-Up", dongs: 4, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Katfish", dongs: 3, drops: 0, doublePlays: 1, salamies: 1, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Summer Camp", dongs: 3, drops: 0, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Baby Boi", dongs: 2, drops: 0, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "The Swarm", dongs: 2, drops: 0, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Golf Shotz", dongs: 2, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Dong Quixote", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "8Ball", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Puppet Master", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Otto", dongs: 0, drops: 0, doublePlays: 0, salamies: 1, wins: 4, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Uncle Kimmy", dongs: 0, drops: 0, doublePlays: 0, salamies: 0, wins: 4, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Reece", dongs: 0, drops: 0, doublePlays: 1, salamies: 0, wins: 3, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Pantera Rosa", dongs: 0, drops: 0, doublePlays: 0, salamies: 0, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Deadliest Catch", dongs: 0, drops: 0, doublePlays: 0, salamies: 0, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Dave", dongs: 0, drops: 0, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Nuri", dongs: 0, drops: 0, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Alex", dongs: 0, drops: 0, doublePlays: 0, salamies: 1, wins: 0, dongRobs: 1)
            ]
        ),

        // Season 7: Strictly Business
        HistoricalSeasonStats(
            seasonNumber: 7,
            seasonName: "Strictly Business",
            playerStats: [
                HistoricalPlayerSeasonStats(playerName: "Flash Dance", dongs: 89, drops: 0, doublePlays: 1, salamies: 4, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Dong Robber", dongs: 50, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Cuidado", dongs: 49, drops: 0, doublePlays: 1, salamies: 2, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Surgeon", dongs: 34, drops: 0, doublePlays: 0, salamies: 2, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Cojones", dongs: 33, drops: 0, doublePlays: 0, salamies: 5, wins: 0, dongRobs: 1),
                HistoricalPlayerSeasonStats(playerName: "Extra Credit", dongs: 31, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 1),
                HistoricalPlayerSeasonStats(playerName: "Party Platter", dongs: 30, drops: 0, doublePlays: 2, salamies: 1, wins: 0, dongRobs: 1),
                HistoricalPlayerSeasonStats(playerName: "The Deal", dongs: 26, drops: 0, doublePlays: 1, salamies: 2, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Candyman", dongs: 26, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 1),
                HistoricalPlayerSeasonStats(playerName: "Barely Bonds", dongs: 24, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Boogie Joe", dongs: 18, drops: 0, doublePlays: 1, salamies: 2, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Jeffrey Bomber", dongs: 15, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Salary", dongs: 12, drops: 0, doublePlays: 0, salamies: 2, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Goat Cheese", dongs: 11, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Dave", dongs: 8, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Slacker", dongs: 8, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Baby Boi", dongs: 8, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Lunch Money", dongs: 7, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Big Whoop", dongs: 5, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Silky", dongs: 5, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Hot Tub", dongs: 3, drops: 0, doublePlays: 0, salamies: 1, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Brunch", dongs: 3, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Summer Camp", dongs: 3, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Gus", dongs: 3, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Jugalo", dongs: 2, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Uncle Kimmy", dongs: 1, drops: 0, doublePlays: 1, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Katfish", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Dan The Fister", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Praveen", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Brett", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0)
            ]
        ),

        // Season 8: Brand New Baby (current season totals)
        HistoricalSeasonStats(
            seasonNumber: 8,
            seasonName: "Brand New Baby",
            playerStats: [
                HistoricalPlayerSeasonStats(playerName: "Surgeon", dongs: 26, drops: 4, doublePlays: 1, salamies: 1, wins: 5, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Flash Dance", dongs: 21, drops: 4, doublePlays: 0, salamies: 1, wins: 4, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Dong Robber", dongs: 16, drops: 5, doublePlays: 1, salamies: 1, wins: 4, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Lunch Money", dongs: 13, drops: 7, doublePlays: 0, salamies: 2, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Cuidado", dongs: 13, drops: 7, doublePlays: 0, salamies: 0, wins: 3, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Boogie Joe", dongs: 8, drops: 12, doublePlays: 0, salamies: 0, wins: 3, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Goat Cheese", dongs: 8, drops: 3, doublePlays: 0, salamies: 0, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "The Deal", dongs: 7, drops: 14, doublePlays: 1, salamies: 0, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Cojones", dongs: 4, drops: 6, doublePlays: 2, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Barely Bonds", dongs: 4, drops: 10, doublePlays: 0, salamies: 0, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Candyman", dongs: 3, drops: 4, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Salary", dongs: 3, drops: 3, doublePlays: 0, salamies: 0, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Adam", dongs: 3, drops: 1, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "White Noize", dongs: 3, drops: 11, doublePlays: 0, salamies: 1, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Coop", dongs: 3, drops: 1, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Grom", dongs: 3, drops: 4, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Slacker", dongs: 2, drops: 6, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Katfish", dongs: 0, drops: 1, doublePlays: 1, salamies: 0, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Party Platter", dongs: 1, drops: 4, doublePlays: 0, salamies: 0, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Hot Tub", dongs: 1, drops: 1, doublePlays: 0, salamies: 0, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Derek", dongs: 1, drops: 11, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Jackson", dongs: 1, drops: 0, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Uncle Kimmy", dongs: 0, drops: 8, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Baby Boi", dongs: 0, drops: 2, doublePlays: 0, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Summer Camp", dongs: 0, drops: 3, doublePlays: 1, salamies: 0, wins: 1, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Extra Credit", dongs: 0, drops: 1, doublePlays: 0, salamies: 0, wins: 2, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "The Swarm", dongs: 0, drops: 3, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Aiden", dongs: 0, drops: 0, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Natural", dongs: 0, drops: 1, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Puppet Master", dongs: 0, drops: 1, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Hot Dog", dongs: 0, drops: 2, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Danger", dongs: 0, drops: 1, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0),
                HistoricalPlayerSeasonStats(playerName: "Rookie Han", dongs: 0, drops: 2, doublePlays: 0, salamies: 0, wins: 0, dongRobs: 0)
            ]
        )
    ]

    /// Calculate career stats for all players across all seasons
    static func calculateCareerStats() -> [CareerStats] {
        var careerDict: [String: CareerStats] = [:]

        for season in seasons {
            for playerSeason in season.playerStats {
                let canonicalName = PlayerAliases.canonicalName(for: playerSeason.playerName)

                if careerDict[canonicalName] == nil {
                    careerDict[canonicalName] = CareerStats(playerName: canonicalName)
                }

                careerDict[canonicalName]?.add(season: playerSeason)
            }
        }

        return Array(careerDict.values).sorted { $0.totalDongs > $1.totalDongs }
    }
}
