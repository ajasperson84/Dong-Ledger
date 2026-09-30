//
//  SplashView.swift
//  Dong Country Ledger 5000
//
//  Opening splash: the Dong Country Ledger 5000 headline slams onto the
//  screen, then the Season 9 banner. Each hit shakes the screen, flashes,
//  throws a gold shockwave and thumps the haptics. Tap to skip.
//

import SwiftUI
import UIKit

struct SplashView: View {
    @Binding var isActive: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var headlineLanded = false
    @State private var subheadLanded = false
    @State private var shakes: CGFloat = 0
    @State private var flashOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.3
    @State private var ringOpacity: Double = 0
    @State private var ringY: CGFloat = 0.40

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("SR_Splash_Background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .scaleEffect(1.06) // overscan so the shake never shows the edges
                    .clipped()

                // Shockwave from the impact point
                Circle()
                    .stroke(SRColors.goldGradient, lineWidth: 6)
                    .frame(width: geo.size.width * 0.8, height: geo.size.width * 0.8)
                    .scaleEffect(ringScale)
                    .opacity(ringOpacity)
                    .blur(radius: 1.5)
                    .position(x: geo.size.width / 2, y: geo.size.height * ringY)

                VStack(spacing: -geo.size.width * 0.04) {
                    Image("SR_Splash_Headline")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geo.size.width * 0.94)
                        .modifier(SlamIn(landed: headlineLanded, startScale: 3.2, startRotation: -8))
                        .accessibilityLabel("Dong Country Ledger 5000")

                    Image("SR_Splash_Season_9")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geo.size.width * 0.9)
                        .modifier(SlamIn(landed: subheadLanded, startScale: 2.6, startRotation: 6))
                        .accessibilityLabel("Season 9: Stickball Rich")
                }
                .position(x: geo.size.width / 2, y: geo.size.height * 0.46)

                Color.white
                    .opacity(flashOpacity)
                    .allowsHitTesting(false)
            }
            .modifier(ImpactShake(animatableData: shakes))
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture { finish() }
        .task { await runSequence() }
    }

    // MARK: - Sequence

    private func runSequence() async {
        if reduceMotion {
            withAnimation(.easeIn(duration: 0.4)) { headlineLanded = true }
            withAnimation(.easeIn(duration: 0.4).delay(0.4)) { subheadLanded = true }
            guard await pause(2.2) else { return }
            finish()
            return
        }

        guard await pause(0.35) else { return }
        withAnimation(.spring(response: 0.26, dampingFraction: 0.55)) {
            headlineLanded = true
        }
        guard await pause(0.16) else { return }
        impact(atY: 0.40, strength: .heavy)

        guard await pause(0.55) else { return }
        withAnimation(.spring(response: 0.24, dampingFraction: 0.6)) {
            subheadLanded = true
        }
        guard await pause(0.15) else { return }
        impact(atY: 0.56, strength: .rigid)

        guard await pause(1.6) else { return }
        finish()
    }

    /// Waits, returning false if the splash was dismissed (task cancelled)
    private func pause(_ seconds: Double) async -> Bool {
        do {
            try await Task.sleep(for: .seconds(seconds))
            return true
        } catch {
            return false
        }
    }

    /// Shake, flash, shockwave and haptic thump when a graphic lands
    private func impact(atY y: CGFloat, strength: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: strength).impactOccurred(intensity: 1.0)

        withAnimation(.linear(duration: 0.4)) {
            shakes += 1
        }

        flashOpacity = 0.55
        withAnimation(.easeOut(duration: 0.35)) {
            flashOpacity = 0
        }

        ringY = y
        ringScale = 0.3
        ringOpacity = 0.9
        withAnimation(.easeOut(duration: 0.6)) {
            ringScale = 1.8
            ringOpacity = 0
        }
    }

    private func finish() {
        guard isActive else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            isActive = false
        }
    }
}

// MARK: - Slam In
/// Starts huge, tilted and invisible, then lands at full size
private struct SlamIn: ViewModifier {
    let landed: Bool
    let startScale: CGFloat
    let startRotation: Double

    func body(content: Content) -> some View {
        content
            .scaleEffect(landed ? 1 : startScale)
            .rotationEffect(.degrees(landed ? 0 : startRotation))
            .opacity(landed ? 1 : 0)
            .blur(radius: landed ? 0 : 6)
            .shadow(color: .black.opacity(0.7), radius: landed ? 10 : 30, x: 0, y: landed ? 6 : 30)
    }
}

// MARK: - Impact Shake
/// Each whole-number step of animatableData is one decaying shake
private struct ImpactShake: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let progress = animatableData - floor(animatableData)
        guard progress > 0 else { return ProjectionTransform(.identity) }
        let decay = 1 - progress
        let x = 14 * decay * sin(progress * .pi * 8)
        let y = 9 * decay * cos(progress * .pi * 10)
        return ProjectionTransform(CGAffineTransform(translationX: x, y: y))
    }
}

#Preview {
    SplashView(isActive: .constant(true))
}
