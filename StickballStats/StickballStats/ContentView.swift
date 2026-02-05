//
//  ContentView.swift
//  StickballStats
//
//  Main navigation view with Tron aesthetic
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var statsService: StatsService
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            // Tron grid background
            TronGridBackground()

            // Main content
            TabView(selection: $selectedTab) {
                WeeklyStatsView()
                    .tabItem {
                        Label("WEEKLY", systemImage: "calendar.badge.clock")
                    }
                    .tag(0)

                LeaderboardView()
                    .tabItem {
                        Label("RANKINGS", systemImage: "trophy")
                    }
                    .tag(1)

                PlayersView()
                    .tabItem {
                        Label("PLAYERS", systemImage: "person.3")
                    }
                    .tag(2)
            }
            .tint(TronColors.cyan)
        }
        .onAppear {
            configureTabBarAppearance()
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(TronColors.darkBackground)

        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(TronColors.dimText)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(TronColors.dimText),
            .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .medium)
        ]

        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(TronColors.cyan)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(TronColors.cyan),
            .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .bold)
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Header Component
struct TronHeader: View {
    let title: String
    let subtitle: String?

    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(TronColors.cyan)
                .neonGlow(color: TronColors.cyan, radius: 10)

            if let subtitle = subtitle {
                Text(subtitle.uppercased())
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(TronColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}

#Preview {
    ContentView()
        .environmentObject(StatsService())
}
