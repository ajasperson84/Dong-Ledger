//
//  SeasonSchedule.swift
//  Dong Country Ledger 5000
//
//  Season schedule with game dates, special events, and fields
//

import Foundation

// MARK: - Game Fields
enum GameField: String, CaseIterable, Codable {
    case theDam = "The Dam"
    case theSpreadingGrounds = "The Spreading Grounds"
    case theAirfield = "The Airfield"

    var shortName: String {
        switch self {
        case .theDam: return "DAM"
        case .theSpreadingGrounds: return "SPRD"
        case .theAirfield: return "AIR"
        }
    }
}

// MARK: - Special Event
enum SpecialEvent: String {
    case newYearsBabyCup = "New Years Baby Cup"
    case allStarGame = "All Star Game"
    case theGalactics = "The Galactics"
    case dadsVsLads = "Dads Vs Lads"
    case theEnd = "The End"

    var shortName: String {
        switch self {
        case .newYearsBabyCup: return "BABY CUP"
        case .allStarGame: return "ALL STAR"
        case .theGalactics: return "GALACTICS"
        case .dadsVsLads: return "DVL"
        case .theEnd: return "CHAMPIONSHIP"
        }
    }
}

// MARK: - Game Week
struct GameWeek: Identifiable, Equatable {
    let id: Int  // Week number (1-based)
    let date: Date
    let specialEvent: SpecialEvent?

    var weekNumber: Int { id }

    var year: Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: date)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    var shortFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    var displayTitle: String {
        if let event = specialEvent {
            return event.rawValue
        }
        return "Week \(weekNumber)"
    }
}

// MARK: - Season Schedule
class SeasonSchedule {
    static let shared = SeasonSchedule()

    let gameWeeks: [GameWeek]
    let seasonStart: Date
    let seasonEnd: Date

    // Special event dates (month, day, year)
    private let specialEvents: [(month: Int, day: Int, year: Int, event: SpecialEvent)] = [
        (1, 10, 2026, .newYearsBabyCup),
        (2, 21, 2026, .allStarGame),
        (4, 25, 2026, .theGalactics),
        (5, 9, 2026, .dadsVsLads),
        (6, 6, 2026, .theEnd)
    ]

    private init() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        // Season: Nov 1, 2025 to June 6, 2026
        // Games every Saturday except Dec 27, 2025 (Christmas/New Years week)

        let startComponents = DateComponents(year: 2025, month: 11, day: 1)
        let endComponents = DateComponents(year: 2026, month: 6, day: 6)

        guard let start = calendar.date(from: startComponents),
              let end = calendar.date(from: endComponents) else {
            self.gameWeeks = []
            self.seasonStart = Date()
            self.seasonEnd = Date()
            return
        }

        self.seasonStart = start
        self.seasonEnd = end

        // Skip date: Dec 27, 2025
        let skipComponents = DateComponents(year: 2025, month: 12, day: 27)
        let skipDate = calendar.date(from: skipComponents)

        var weeks: [GameWeek] = []
        var currentDate = start
        var weekNumber = 1

        // Nov 1, 2025 is a Saturday, so we start there
        while currentDate <= end {
            // Check if this is the skip date
            if let skip = skipDate, calendar.isDate(currentDate, inSameDayAs: skip) {
                // Skip this week, move to next Saturday
                if let nextSaturday = calendar.date(byAdding: .day, value: 7, to: currentDate) {
                    currentDate = nextSaturday
                }
                continue
            }

            // Check for special event
            let components = calendar.dateComponents([.month, .day, .year], from: currentDate)
            let specialEvent = specialEvents.first {
                $0.month == components.month &&
                $0.day == components.day &&
                $0.year == components.year
            }?.event

            let gameWeek = GameWeek(id: weekNumber, date: currentDate, specialEvent: specialEvent)
            weeks.append(gameWeek)

            weekNumber += 1

            // Move to next Saturday
            if let nextSaturday = calendar.date(byAdding: .day, value: 7, to: currentDate) {
                currentDate = nextSaturday
            } else {
                break
            }
        }

        self.gameWeeks = weeks
    }

    // Get the current week index (most recent game that has occurred)
    func currentWeekIndex() -> Int {
        let today = Date()
        var lastPlayedIndex = 0

        for (index, week) in gameWeeks.enumerated() {
            if week.date <= today {
                lastPlayedIndex = index
            } else {
                break
            }
        }

        return lastPlayedIndex
    }

    // Get game week by week number (1-based)
    func gameWeek(forWeekNumber weekNumber: Int) -> GameWeek? {
        return gameWeeks.first { $0.weekNumber == weekNumber }
    }

    // Get game week by index (0-based)
    func gameWeek(atIndex index: Int) -> GameWeek? {
        guard index >= 0 && index < gameWeeks.count else { return nil }
        return gameWeeks[index]
    }

    // Check if a week is in the future (hasn't been played yet)
    func isFutureWeek(index: Int) -> Bool {
        guard let week = gameWeek(atIndex: index) else { return true }
        return week.date > Date()
    }

    // Get total number of weeks in season
    var totalWeeks: Int {
        return gameWeeks.count
    }
}
