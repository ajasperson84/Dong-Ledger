//
//  SplashView.swift
//  StickballStats
//
//  Tron-style animated splash screen
//

import SwiftUI

struct SplashView: View {
    @State private var showLogo = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var glowIntensity: CGFloat = 0
    @State private var gridOpacity: CGFloat = 0
    @Binding var isActive: Bool

    var body: some View {
        ZStack {
            // Animated grid background
            TronGridBackground()
                .opacity(gridOpacity)

            VStack(spacing: 30) {
                // Logo
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(TronColors.cyan, lineWidth: 3)
                        .frame(width: 160, height: 160)
                        .shadow(color: TronColors.cyan.opacity(glowIntensity), radius: 20)
                        .shadow(color: TronColors.cyan.opacity(glowIntensity * 0.5), radius: 40)

                    // Inner ring
                    Circle()
                        .stroke(TronColors.cyan.opacity(0.5), lineWidth: 1)
                        .frame(width: 140, height: 140)

                    // Center icon - stylized "D" for Dong
                    Text("D")
                        .font(.system(size: 80, weight: .black, design: .monospaced))
                        .foregroundColor(TronColors.cyan)
                        .shadow(color: TronColors.cyan.opacity(glowIntensity), radius: 10)
                        .shadow(color: TronColors.cyan.opacity(glowIntensity * 0.7), radius: 20)

                    // Decorative lines
                    ForEach(0..<4) { i in
                        Rectangle()
                            .fill(TronColors.cyan)
                            .frame(width: 2, height: 20)
                            .offset(y: -90)
                            .rotationEffect(.degrees(Double(i) * 90))
                            .shadow(color: TronColors.cyan.opacity(glowIntensity), radius: 5)
                    }
                }
                .scaleEffect(showLogo ? 1.0 : 0.5)
                .opacity(showLogo ? 1.0 : 0)

                // Title
                VStack(spacing: 8) {
                    Text("DONG COUNTRY")
                        .font(.system(size: 32, weight: .black, design: .monospaced))
                        .foregroundColor(TronColors.cyan)
                        .shadow(color: TronColors.cyan.opacity(glowIntensity), radius: 10)
                        .shadow(color: TronColors.cyan.opacity(glowIntensity * 0.5), radius: 20)
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 20)

                    Text("LEDGER 5000")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(TronColors.orange)
                        .shadow(color: TronColors.orange.opacity(glowIntensity), radius: 10)
                        .shadow(color: TronColors.orange.opacity(glowIntensity * 0.5), radius: 20)
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 20)
                }

                // Subtitle
                Text("STICKBALL STATISTICS SYSTEM")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(TronColors.dimText)
                    .tracking(4)
                    .opacity(showSubtitle ? 1 : 0)
            }

            // Scan line effect
            ScanLineEffect()
                .opacity(0.1)
        }
        .background(TronColors.darkBackground)
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // Grid fade in
        withAnimation(.easeIn(duration: 0.5)) {
            gridOpacity = 1
        }

        // Logo appears
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
            showLogo = true
        }

        // Glow pulses
        withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
            glowIntensity = 1.0
        }

        // Title appears
        withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
            showTitle = true
        }

        // Subtitle appears
        withAnimation(.easeOut(duration: 0.5).delay(1.1)) {
            showSubtitle = true
        }

        // Transition to main app
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isActive = false
            }
        }
    }
}

// MARK: - Scan Line Effect
struct ScanLineEffect: View {
    @State private var offset: CGFloat = -1000

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            TronColors.cyan.opacity(0.3),
                            TronColors.cyan.opacity(0.5),
                            TronColors.cyan.opacity(0.3),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 100)
                .offset(y: offset)
                .onAppear {
                    withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                        offset = geometry.size.height + 100
                    }
                }
        }
    }
}

#Preview {
    SplashView(isActive: .constant(true))
}
