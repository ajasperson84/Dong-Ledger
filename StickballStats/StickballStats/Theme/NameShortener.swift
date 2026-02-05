//
//  NameShortener.swift
//  Dong Country Ledger 5000
//
//  Utility to shorten player names for stat line display
//  Rules:
//  - Single word: first 3-4 chars (e.g., "Salary" -> "Sal")
//  - Two+ words: initials (e.g., "Dong Robber" -> "DR")
//  - "The X": drop "The", use X (e.g., "The Deal" -> "Deal")
//  - Max 4 characters, no line breaks
//

import Foundation

extension String {
    /// Returns a shortened version of the name for stat line display
    /// Max 4 characters, optimized for readability
    var shortName: String {
        let trimmed = self.trimmingCharacters(in: .whitespaces)
        let words = trimmed.split(separator: " ").map { String($0) }

        guard !words.isEmpty else { return "" }

        // Handle "The X" pattern - drop "The" and use the next word
        if words.count >= 2 && words[0].lowercased() == "the" {
            let secondWord = words[1]
            // Return up to 4 characters of the second word
            return String(secondWord.prefix(4)).uppercased()
        }

        // Single word name - return first 3-4 characters
        if words.count == 1 {
            let name = words[0]
            // Use 3 chars for shorter names, 4 for longer
            let length = name.count <= 5 ? 3 : 4
            return String(name.prefix(length)).uppercased()
        }

        // Multiple words - use initials (max 4)
        let initials = words.prefix(4).compactMap { $0.first }.map { String($0) }.joined()
        return initials.uppercased()
    }
}
