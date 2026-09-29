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
    case uncleKimmysPlayhouse = "Uncle Kimmy's Playhouse"

    var shortName: String {
        switch self {
        case .theDam: return "DAM"
        case .theSpreadingGrounds: return "SPRD"
        case .theAirfield: return "AIR"
        case .uncleKimmysPlayhouse: return "UKP"
        }
    }

    var icon: String {
        switch self {
        case .theDam: return "water.waves"
        case .theSpreadingGrounds: return "leaf.fill"
        case .theAirfield: return "airplane"
        case .uncleKimmysPlayhouse: return "moon.stars.fill"
        }
    }

    /// Uncle Kimmy's Playhouse hosts the monthly Saturday night game
    var isNightGame: Bool {
        self == .uncleKimmysPlayhouse
    }
}

// MARK: - Special Event
enum SpecialEvent: String {
    case coattailClassic = "The Coattail Classic"
    case theWideOpen = "The Wide Open"
    case dadsVsLads = "Dads Vs Lads"
    case theEnd = "The End"

    var shortName: String {
        switch self {
        case .coattailClassic: return "COATTAIL"
        case .theWideOpen: return "WIDE OPEN"
        case .dadsVsLads: return "DVL"
        case .theEnd: return "CHAMPIONSHIP"
        }
    }

    /// Extra line shown under the event name
    var subtitle: String? {
        switch self {
        case .coattailClassic: return "LA vs Portland · 4-team tournament"
        case .theWideOpen: return "Apr 1–4 · National tournament · No league game"
        default: return nil
        }
    }

    /// Blocked-out weekends have no league game and no stat entry
    var isBlockedOut: Bool {
        self == .theWideOpen
    }

    /// Portland chapter players can be added to this week
    var includesPortland: Bool {
        self == .coattailClassic
    }
}

// MARK: - Game Week
struct GameWeek: Identifiable, Equatable {
    let id: Int  // Week number (1-based)
    let date: Date
    let specialEvent: SpecialEvent?

    var weekNumber: Int { id }

    var isBlockedOut: Bool { specialEvent?.isBlockedOut ?? false }

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

    /// Season number used by the archive (Season 8 was Nov 2025 – Jun 2026)
    let seasonNumber = 9

    let gameWeeks: [GameWeek]
    let seasonStart: Date
    let seasonEnd: Date

    // Special event dates (month, day, year)
    private let specialEvents: [(month: Int, day: Int, year: Int, event: SpecialEvent)] = [
        (11, 14, 2026, .coattailClassic),
        (4, 3, 2027, .theWideOpen),
        (5, 8, 2027, .dadsVsLads),
        (6, 12, 2027, .theEnd)
    ]

    // Saturdays with no game
    private let skipDates: [(month: Int, day: Int, year: Int)] = [
        (12, 26, 2026),
        (1, 2, 2027)
    ]

    private init() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        // Season: Oct 24, 2026 to June 12, 2027
        // Games every Saturday except Dec 26, 2026 and Jan 2, 2027

        let startComponents = DateComponents(year: 2026, month: 10, day: 24)
        let endComponents = DateComponents(year: 2027, month: 6, day: 12)

        guard let start = calendar.date(from: startComponents),
              let end = calendar.date(from: endComponents) else {
            self.gameWeeks = []
            self.seasonStart = Date()
            self.seasonEnd = Date()
            return
        }

        self.seasonStart = start
        self.seasonEnd = end

        let skips = skipDates.compactMap {
            calendar.date(from: DateComponents(year: $0.year, month: $0.month, day: $0.day))
        }

        var weeks: [GameWeek] = []
        var currentDate = start
        var weekNumber = 1

        // Oct 24, 2026 is a Saturday, so we start there
        while currentDate <= end {
            if skips.contains(where: { calendar.isDate(currentDate, inSameDayAs: $0) }) {
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
