//
//  ContentView.swift
//  Dong Country Ledger 5000
//
//  Main navigation with the Stickball Rich tab bar
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var statsService: StatsService
    @State private var selectedTab = 0
    @State private var showingSplash = true

    var body: some View {
        ZStack {
            if showingSplash {
                SplashView(isActive: $showingSplash)
                    .transition(.opacity)
            } else {
                mainContent
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingSplash)
    }

    private var mainContent: some View {
        // Leaderboard is first (main page). All four tabs stay alive so each
        // keeps its scroll position and state; only the selected one is shown.
        ZStack {
            tab(.season) { LeaderboardView() }
            tab(.weekly) { WeeklyStatsView() }
            tab(.historic) { PastSeasonsView() }
            tab(.players) { PlayersView() }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SRTabBar(selection: $selectedTab)
        }
        .background(SRBackground())
    }

    private func tab<Content: View>(_ tab: SRTab, @ViewBuilder content: () -> Content) -> some View {
        let isSelected = selectedTab == tab.rawValue
        return content()
            .opacity(isSelected ? 1 : 0)
            .allowsHitTesting(isSelected)
            .accessibilityHidden(!isSelected)
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
