//
//  Player.swift
//  StickballStats
//

import Foundation
import FirebaseFirestore

struct Player: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var jerseyNumber: Int?
    var teamName: String?
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    init(name: String, jerseyNumber: Int? = nil, teamName: String? = nil) {
        self.name = name
        self.jerseyNumber = jerseyNumber
        self.teamName = teamName
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // Computed property for display
    var displayName: String {
        if let number = jerseyNumber {
            return "#\(number) \(name)"
        }
        return name
    }
}
