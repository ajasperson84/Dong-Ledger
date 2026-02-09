//
//  AdminService.swift
//  Dong Country Ledger 5000
//
//  Admin mode management with PIN authentication
//

import Foundation
import SwiftUI

@MainActor
class AdminService: ObservableObject {
    static let shared = AdminService()

    // The admin PIN
    private let adminPIN = "2234"

    // Admin mode state (resets when app closes)
    @Published private(set) var isAdminMode: Bool = false

    init() {}

    /// Attempt to enable admin mode with the given PIN
    /// Returns true if PIN is correct, false otherwise
    func authenticate(pin: String) -> Bool {
        if pin == adminPIN {
            isAdminMode = true
            return true
        }
        return false
    }

    /// Exit admin mode
    func logout() {
        isAdminMode = false
    }
}
