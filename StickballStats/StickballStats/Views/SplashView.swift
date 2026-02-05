//
//  SplashView.swift
//  Dong Country Ledger 5000
//
//  Tron-style animated splash screen with stacked word reveal
//

import SwiftUI

struct SplashView: View {
    @State private var showDong = false
    @State private var showCountry = false
    @State private var showLedger = false
    @State private var show5000 = false
    @State private var glowIntensity: CGFloat = 0
    @Binding var isActive: Bool

    var body: some View {
        ZStack {
            // Background
            TronColors.darkBackground
                .ignoresSafeArea()

            // Grid overlay
            TronGridBackground()
                .opacity(0.5)

            // Stacked words
            VStack(spacing: 0) {
                // DONG
                Text("DONG")
                    .font(.system(size: 72, weight: .black, design: .monospaced))
                    .foregroundColor(TronColors.cyan)
                    .shadow(color: TronColors.cyan.opacity(glowIntensity), radius: 20)
                    .shadow(color: TronColors.cyan.opacity(glowIntensity * 0.5), radius: 40)
                    .opacity(showDong ? 1 : 0)
                    .scaleEffect(showDong ? 1 : 0.5)

                // COUNTRY
                Text("COUNTRY")
                    .font(.system(size: 56, weight: .black, design: .monospaced))
                    .foregroundColor(TronColors.cyan)
                    .shadow(color: TronColors.cyan.opacity(glowIntensity), radius: 20)
                    .shadow(color: TronColors.cyan.opacity(glowIntensity * 0.5), radius: 40)
                    .opacity(showCountry ? 1 : 0)
                    .scaleEffect(showCountry ? 1 : 0.5)

                // LEDGER
                Text("LEDGER")
                    .font(.system(size: 56, weight: .bold, design: .monospaced))
                    .foregroundColor(TronColors.orange)
                    .shadow(color: TronColors.orange.opacity(glowIntensity), radius: 20)
                    .shadow(color: TronColors.orange.opacity(glowIntensity * 0.5), radius: 40)
                    .opacity(showLedger ? 1 : 0)
                    .scaleEffect(showLedger ? 1 : 0.5)

                // 5000
                Text("5000")
                    .font(.system(size: 80, weight: .black, design: .monospaced))
                    .foregroundColor(TronColors.orange)
                    .shadow(color: TronColors.orange.opacity(glowIntensity), radius: 25)
                    .shadow(color: TronColors.orange.opacity(glowIntensity * 0.5), radius: 50)
                    .opacity(show5000 ? 1 : 0)
                    .scaleEffect(show5000 ? 1 : 0.5)
            }

            // Scan line effect
            ScanLineEffect()
                .opacity(0.1)
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // DONG appears
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
            showDong = true
        }

        // COUNTRY appears
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5)) {
            showCountry = true
        }

        // LEDGER appears
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.8)) {
            showLedger = true
        }

        // 5000 appears
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.1)) {
            show5000 = true
        }

        // Glow intensifies
        withAnimation(.easeInOut(duration: 0.8).delay(1.3)) {
            glowIntensity = 1.0
        }

        // Transition to main app
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
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
