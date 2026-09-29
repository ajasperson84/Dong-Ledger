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

    /// teamName used to mark visiting players from the Portland chapter
    static let portlandChapter = "Portland"

    /// Portland players only play in the Coattail Classic and don't count toward LA stats
    var isPortland: Bool {
        teamName == Player.portlandChapter
    }

    // Computed property for display
    var displayName: String {
        if let number = jerseyNumber {
            return "#\(number) \(name)"
        }
        return name
    }
}
