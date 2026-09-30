//
//  StickballRichTheme.swift
//  Dong Country Ledger 5000
//
//  "Stickball Rich" gold, diamond and black-marble skin built from the
//  image layers in Assets.xcassets/StickballRich (all prefixed "SR_").
//

import SwiftUI
import CoreText

// MARK: - Fonts
enum SRFont {
    /// Condensed bold serif for names, dates and gold headings
    static func display(_ size: CGFloat) -> Font { .custom("AbrilFatface-Regular", size: size) }
    /// Heavy slab serif for list titles (Players, Past Seasons)
    static func slab(_ size: CGFloat) -> Font { .custom("Ultra-Regular", size: size) }
    /// Typewriter text for subtitles
    static func mono(_ size: CGFloat) -> Font { .custom("CourierPrime-Bold", size: size) }

    /// Registers the bundled fonts so no Info.plist entry is needed
    static func registerAll() {
        for name in ["AbrilFatface-Regular", "Ultra-Regular", "CourierPrime-Bold"] {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                print("⚠️ Missing font \(name)")
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

// MARK: - Colors
enum SRColors {
    static let gold = Color(red: 0.96, green: 0.78, blue: 0.36)
    static let goldLight = Color(red: 1.0, green: 0.90, blue: 0.62)
    static let goldDark = Color(red: 0.62, green: 0.42, blue: 0.10)
    static let purple = Color(red: 0.62, green: 0.30, blue: 1.0)
    static let pink = Color(red: 0.93, green: 0.45, blue: 1.0)
    static let marble = Color(red: 0.05, green: 0.04, blue: 0.05)
    static let text = Color(red: 0.99, green: 0.97, blue: 0.92)

    static let goldGradient = LinearGradient(
        colors: [goldLight, gold, goldDark, gold],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Background
struct SRBackground: View {
    var body: some View {
        GeometryReader { geo in
            Image("SR_Stickball_Rich_Background_1290w")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
}

// MARK: - Screen Header
/// Stickball Rich title with a page banner tucked under it
struct SRHeader: View {
    let banner: String
    var titleWidth: CGFloat = 0.86
    var bannerWidth: CGFloat = 0.84

    var body: some View {
        VStack(spacing: -18) {
            Image("SR_Stickball_Rich_Title")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .containerRelativeFrame(.horizontal) { width, _ in width * titleWidth }
            Image(banner)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .containerRelativeFrame(.horizontal) { width, _ in width * bannerWidth }
        }
        .frame(maxWidth: .infinity)
    }
}

/// Crossed dowels and TTFB logo shown at the bottom of each list
struct SRFooterLogo: View {
    var body: some View {
        Image("SR_TBT_Crossed_Dowels")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(.horizontal, 24)
            .padding(.top, 8)
    }
}

// MARK: - Diamond Numbers
/// Builds a number out of the diamond digit images
struct DiamondNumber: View {
    let value: Int
    let height: CGFloat

    private var digits: [Character] { Array(String(max(0, value))) }

    var body: some View {
        HStack(spacing: -height * 0.16) {
            ForEach(Array(digits.enumerated()), id: \.offset) { _, digit in
                Image("SR_Diamond_Digit_\(digit)")
                    .resizable()
                    .aspectRatio(180.0 / 253.0, contentMode: .fit)
                    .frame(height: height)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("\(value)")
    }
}

/// Crown-and-laurel medallion with a diamond rank number
struct RankBadge: View {
    let rank: Int
    var size: CGFloat = 58

    var body: some View {
        ZStack {
            Image("SR_Rank_Badge_Blank_1500")
                .resizable()
                .aspectRatio(contentMode: .fit)
            DiamondNumber(value: rank, height: size * (rank >= 10 ? 0.30 : 0.38))
                .offset(y: size * 0.05)
        }
        .frame(width: size, height: size)
    }
}

/// Leaderboard row: rank medallion, player name and diamond total
struct SRRankRow: View {
    let rank: Int
    let name: String
    let value: Int

    var body: some View {
        SRArtPlate("SR_Player_Row_Empty") { size in
            HStack(spacing: 10) {
                RankBadge(rank: rank, size: size.height * 0.92)

                Text(name.uppercased())
                    .font(SRFont.display(size.height * 0.34))
                    .foregroundColor(SRColors.text)
                    .shadow(color: .black, radius: 1, x: 0, y: 1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Spacer(minLength: 4)

                DiamondNumber(value: value, height: size.height * 0.56)
            }
            .padding(.leading, size.width * 0.04)
            .padding(.trailing, size.width * 0.07)
        }
    }
}

// MARK: - Image Buttons
/// Swaps between the Unselected and Selected art while pressed
struct SRImageButtonStyle: ButtonStyle {
    let normal: String
    let pressed: String

    func makeBody(configuration: Configuration) -> some View {
        Image(configuration.isPressed ? pressed : normal)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .overlay(configuration.label)
            .contentShape(Rectangle())
    }
}

extension ButtonStyle where Self == SRImageButtonStyle {
    /// Uses "SR_<base>_Unselected" / "SR_<base>_Selected"
    static func srImage(_ base: String) -> SRImageButtonStyle {
        SRImageButtonStyle(normal: "SR_\(base)_Unselected", pressed: "SR_\(base)_Selected")
    }
}

/// A piece of plate art at its natural proportions with content laid over it.
/// The content closure gets the plate's rendered size for proportional placement.
struct SRArtPlate<Content: View>: View {
    let image: String
    @ViewBuilder let content: (CGSize) -> Content

    init(_ image: String, @ViewBuilder content: @escaping (CGSize) -> Content) {
        self.image = image
        self.content = content
    }

    var body: some View {
        Image(image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .overlay(
                GeometryReader { geo in
                    content(geo.size)
                        .frame(width: geo.size.width, height: geo.size.height)
                }
            )
    }
}

/// Stretchy black-marble plate with a gold edge, for panels without dedicated art
struct SRPlate: ViewModifier {
    var glow: Color = SRColors.gold
    var cornerRadius: CGFloat = 10

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(SRColors.marble.opacity(0.92))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(SRColors.goldGradient, lineWidth: 2)
            )
            .shadow(color: glow.opacity(0.45), radius: 6)
    }
}

extension View {
    func srPlate(glow: Color = SRColors.gold, cornerRadius: CGFloat = 10) -> some View {
        modifier(SRPlate(glow: glow, cornerRadius: cornerRadius))
    }

    /// Gold serif heading text
    func srGoldText() -> some View {
        foregroundStyle(SRColors.goldGradient)
            .shadow(color: .black.opacity(0.8), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Tab Bar
enum SRTab: Int, CaseIterable {
    case season, weekly, historic, players

    var title: String {
        switch self {
        case .season: return "SEASON"
        case .weekly: return "WEEKLY"
        case .historic: return "HISTORIC"
        case .players: return "PLAYERS"
        }
    }

    var icon: String {
        switch self {
        case .season: return "SR_Season"
        case .weekly: return "SR_Weekly"
        case .historic: return "SR_Historic"
        case .players: return "SR_Players"
        }
    }
}

struct SRTabBar: View {
    @Binding var selection: Int

    var body: some View {
        ZStack {
            Image("SR_Tab_Bar_Empty")
                .resizable()
                .aspectRatio(contentMode: .fit)

            HStack(spacing: 0) {
                ForEach(SRTab.allCases, id: \.rawValue) { tab in
                    let isSelected = selection == tab.rawValue
                    Button(action: { selection = tab.rawValue }) {
                        VStack(spacing: 0) {
                            Image(isSelected ? tab.icon + "_Selected" : tab.icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 46, height: 46)
                            Text(tab.title)
                                .font(SRFont.display(12))
                                .foregroundColor(isSelected ? SRColors.text : SRColors.gold)
                                .offset(y: -6)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            .padding(.horizontal, 22)
        }
        .padding(.horizontal, 4)
    }
}
