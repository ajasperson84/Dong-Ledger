//
//  StatCounter.swift
//  StickballStats
//
//  Quick increment/decrement control for stats
//

import SwiftUI

struct StatCounter: View {
    let title: String
    @Binding var value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .neonGlow(color: color, radius: 3)

            HStack(spacing: 12) {
                // Decrement button
                Button(action: {
                    if value > 0 {
                        withAnimation(.easeOut(duration: 0.1)) {
                            value -= 1
                        }
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(value > 0 ? color : TronColors.dimText)
                        .frame(width: 32, height: 32)
                        .background(TronColors.surfaceBackground)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(value > 0 ? color.opacity(0.5) : TronColors.dimText.opacity(0.3), lineWidth: 1)
                        )
                }
                .disabled(value <= 0)

                // Value display
                Text("\(value)")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                    .frame(minWidth: 40)
                    .neonGlow(color: color, radius: value > 0 ? 5 : 0)

                // Increment button
                Button(action: {
                    withAnimation(.easeOut(duration: 0.1)) {
                        value += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(color)
                        .frame(width: 32, height: 32)
                        .background(TronColors.surfaceBackground)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(color.opacity(0.5), lineWidth: 1)
                        )
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Compact Stat Display
struct StatBadge: View {
    let title: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .neonGlow(color: color, radius: value > 0 ? 3 : 0)

            Text(title.prefix(4).uppercased())
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(color.opacity(0.7))
        }
        .frame(minWidth: 45)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        TronGridBackground()
        VStack(spacing: 30) {
            StatCounter(title: "Dongs", value: .constant(5), color: TronColors.cyan)
            StatCounter(title: "Drops", value: .constant(2), color: TronColors.orange)

            HStack(spacing: 20) {
                StatBadge(title: "Dongs", value: 12, color: TronColors.cyan)
                StatBadge(title: "Drops", value: 3, color: TronColors.orange)
                StatBadge(title: "DblPly", value: 1, color: TronColors.magenta)
            }
        }
    }
}
