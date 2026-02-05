//
//  StickballStatsApp.swift
//  StickballStats
//
//  Stickball League Statistics Tracker
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct StickballStatsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var statsService = StatsService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(statsService)
                .preferredColorScheme(.dark)
        }
    }
}
