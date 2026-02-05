//
//  GameWeekInfo.swift
//  Dong Country Ledger 5000
//
//  Stores per-week game information like field selection
//

import Foundation
import FirebaseFirestore

struct GameWeekInfo: Identifiable, Codable {
    @DocumentID var id: String?
    var weekNumber: Int
    var field: String?  // GameField raw value
    var createdAt: Date
    var updatedAt: Date

    init(weekNumber: Int, field: GameField? = nil) {
        self.weekNumber = weekNumber
        self.field = field?.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var gameField: GameField? {
        guard let fieldString = field else { return nil }
        return GameField(rawValue: fieldString)
    }

    mutating func setField(_ newField: GameField?) {
        self.field = newField?.rawValue
        self.updatedAt = Date()
    }
}
