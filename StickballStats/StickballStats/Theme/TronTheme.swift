//
//  TronTheme.swift
//  StickballStats
//
//  Retro 1980s Tron-inspired visual theme
//

import SwiftUI

// MARK: - Color Palette
struct TronColors {
    // Primary neon colors
    static let cyan = Color(red: 0.0, green: 0.95, blue: 0.95)
    static let orange = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let magenta = Color(red: 1.0, green: 0.2, blue: 0.6)
    static let green = Color(red: 0.2, green: 1.0, blue: 0.4)
    static let yellow = Color(red: 1.0, green: 0.95, blue: 0.3)
    static let purple = Color(red: 0.6, green: 0.2, blue: 1.0)

    // Background colors
    static let darkBackground = Color(red: 0.02, green: 0.02, blue: 0.08)
    static let cardBackground = Color(red: 0.05, green: 0.05, blue: 0.12)
    static let surfaceBackground = Color(red: 0.08, green: 0.08, blue: 0.15)

    // Grid line color
    static let gridLine = Color(red: 0.1, green: 0.3, blue: 0.4)

    // Text colors
    static let primaryText = Color.white
    static let secondaryText = Color(white: 0.7)
    static let dimText = Color(white: 0.5)
}

// MARK: - Neon Glow Effect
struct NeonGlow: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.8), radius: radius / 2, x: 0, y: 0)
            .shadow(color: color.opacity(0.5), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.3), radius: radius * 1.5, x: 0, y: 0)
    }
}

extension View {
    func neonGlow(color: Color = TronColors.cyan, radius: CGFloat = 10) -> some View {
        modifier(NeonGlow(color: color, radius: radius))
    }
}

// MARK: - Neon Border
struct NeonBorder: ViewModifier {
    let color: Color
    let lineWidth: CGFloat
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: lineWidth)
                    .neonGlow(color: color, radius: 5)
            )
    }
}

extension View {
    func neonBorder(color: Color = TronColors.cyan, lineWidth: CGFloat = 1.5, cornerRadius: CGFloat = 12) -> some View {
        modifier(NeonBorder(color: color, lineWidth: lineWidth, cornerRadius: cornerRadius))
    }
}

// MARK: - Tron Card Style
struct TronCard: ViewModifier {
    let glowColor: Color

    func body(content: Content) -> some View {
        content
            .padding()
            .background(TronColors.cardBackground)
            .cornerRadius(12)
            .neonBorder(color: glowColor)
    }
}

extension View {
    func tronCard(glowColor: Color = TronColors.cyan) -> some View {
        modifier(TronCard(glowColor: glowColor))
    }
}

// MARK: - Tron Button Style
struct TronButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold, design: .monospaced))
            .foregroundColor(configuration.isPressed ? color.opacity(0.7) : color)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(TronColors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 2)
            )
            .neonGlow(color: color, radius: configuration.isPressed ? 15 : 8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == TronButtonStyle {
    static func tron(color: Color = TronColors.cyan) -> TronButtonStyle {
        TronButtonStyle(color: color)
    }
}

// MARK: - Tron Text Field Style
struct TronTextFieldStyle: TextFieldStyle {
    let glowColor: Color

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 16, design: .monospaced))
            .foregroundColor(TronColors.primaryText)
            .padding()
            .background(TronColors.surfaceBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(glowColor.opacity(0.5), lineWidth: 1)
            )
    }
}

// MARK: - Animated Grid Background
struct TronGridBackground: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let gridSpacing: CGFloat = 40
                let lineWidth: CGFloat = 0.5

                // Vertical lines
                for x in stride(from: 0, to: size.width, by: gridSpacing) {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    context.stroke(path, with: .color(TronColors.gridLine.opacity(0.3)), lineWidth: lineWidth)
                }

                // Horizontal lines
                for y in stride(from: 0, to: size.height, by: gridSpacing) {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(path, with: .color(TronColors.gridLine.opacity(0.3)), lineWidth: lineWidth)
                }
            }
        }
        .background(TronColors.darkBackground)
        .ignoresSafeArea()
    }
}

// MARK: - Pulsing Animation
struct PulsingAnimation: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .opacity(isPulsing ? 1.0 : 0.6)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}

extension View {
    func pulsing() -> some View {
        modifier(PulsingAnimation())
    }
}

// MARK: - Stat Category Colors
extension TronColors {
    static func colorForStat(_ stat: String) -> Color {
        switch stat.lowercased() {
        case "dongs":
            return cyan
        case "drops":
            return orange
        case "doubleplays", "double plays":
            return magenta
        case "salamies":
            return green
        case "wins":
            return yellow
        default:
            return cyan
        }
    }
}
