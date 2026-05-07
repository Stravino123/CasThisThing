import SwiftUI

// Single source of truth for all visual constants.
// Use DS.* everywhere — never hardcode colors, radii or spacing in views.
//
// I colori sono dynamic (static var) e leggono ThemeStore.shared.current.
// SwiftUI's @Observable tracking ri-renderizza i componenti automaticamente
// quando l'utente cambia tema.

enum DS {

    // MARK: - Colors

    enum Color {

        // Shortcut interno — evita di ripetere ThemeStore.shared.current ovunque
        private static var premium: Bool { ThemeStore.shared.current == .premium }

        // ── Canvas / background ──────────────────────────────────────────────
        static var canvas: SwiftUI.Color       { premium ? .init(hex: "#1B1B1B") : .init(hex: "#FFF5F7") }

        // ── Primary ──────────────────────────────────────────────────────────
        static var primary: SwiftUI.Color      { premium ? .init(hex: "#F1F1F1") : .init(hex: "#FF006E") }
        static var onPrimary: SwiftUI.Color    { premium ? .init(hex: "#262626") : .init(hex: "#FFFFFF") }
        static var primaryLight: SwiftUI.Color { premium ? .init(hex: "#262626") : .init(hex: "#FFF5F7") }
        static var onPrimaryLight: SwiftUI.Color { premium ? .init(hex: "#FFFFFF") : .init(hex: "#BC004E") }

        // ── Secondary ────────────────────────────────────────────────────────
        static var secondary: SwiftUI.Color    { premium ? .init(hex: "#262626") : .init(hex: "#8FC1CB") }
        static var onSecondary: SwiftUI.Color  { .init(hex: "#FFFFFF") }                // color4/100 — uguale in entrambi

        // ── Borders ──────────────────────────────────────────────────────────
        static var borderGeneral: SwiftUI.Color  { premium ? .init(hex: "#B9B9B9") : .init(hex: "#FDDAE0") }
        static var borderDisabled: SwiftUI.Color { premium ? .init(hex: "#474747") : .init(hex: "#E2E2E2") }
        static var borderDefault: SwiftUI.Color  { premium ? .init(hex: "#474747") : .init(hex: "#D9D9D9") }

        // ── Surface ──────────────────────────────────────────────────────────
        static var general: SwiftUI.Color      { premium ? .init(hex: "#1B1B1B") : .init(hex: "#FFFFFF") }
        static var disabled: SwiftUI.Color     { premium ? .init(hex: "#262626") : .init(hex: "#F8F8F8") }
        static var onDisabled: SwiftUI.Color   { .init(hex: "#B9B9B9") }               // neutral/700 — uguale

        // ── Text ─────────────────────────────────────────────────────────────
        static var text: SwiftUI.Color         { premium ? .init(hex: "#FFFFFF") : .init(hex: "#1B1B1B") }
        static var textSub: SwiftUI.Color      { premium ? .init(hex: "#9E9E9E") : .init(hex: "#767676") }
        static var text1: SwiftUI.Color        { premium ? .init(hex: "#FFFFFF") : .init(hex: "#1B1B1B") }
        static var text2: SwiftUI.Color        { text1.opacity(0.55) }
        static var text3: SwiftUI.Color        { text1.opacity(0.28) }

        // ── Component semantics ──────────────────────────────────────────────
        static var bg: SwiftUI.Color           { canvas }
        static var surface: SwiftUI.Color      { disabled }
        static var surfaceAlt: SwiftUI.Color   { premium ? .init(hex: "#3B3B3B") : .init(hex: "#F1F1F1") }
        static var accent: SwiftUI.Color       { primary }
        static var accentDim: SwiftUI.Color    { primaryLight }
        static var borderPrimary: SwiftUI.Color { primary }
        static var border1: SwiftUI.Color      { borderGeneral }
        static var border2: SwiftUI.Color      { borderGeneral.opacity(0.6) }
        static var border3: SwiftUI.Color      { borderGeneral.opacity(0.3) }
        static var stepDoneFill: SwiftUI.Color { primary }
        static var stepDoneText: SwiftUI.Color { onPrimary }
        static var tooltipBg: SwiftUI.Color    { premium ? .init(hex: "#3B3B3B") : .init(hex: "#262626") }
    }

    // MARK: - Typography

    enum Font {
        static let logo    = excon(size: 14, weight: 700)
        static let title   = excon(size: 20, weight: 700)
        static let body    = excon(size: 15, weight: 400)
        static let label   = excon(size: 13, weight: 500)
        static let caption = excon(size: 11, weight: 400)
        static let mono    = SwiftUI.Font.system(size: 15).monospacedDigit()
        static let monoSm  = SwiftUI.Font.system(size: 13).monospacedDigit()

        static func excon(size: CGFloat, weight: Int = 400) -> SwiftUI.Font {
            .custom("Excon Variable", size: size)
                .weight(fontWeight(weight))
        }

        private static func fontWeight(_ w: Int) -> SwiftUI.Font.Weight {
            switch w {
            case ..<200: return .ultraLight
            case ..<300: return .thin
            case ..<400: return .light
            case ..<500: return .regular
            case ..<600: return .medium
            case ..<700: return .semibold
            case ..<800: return .bold
            case ..<900: return .heavy
            default:     return .black
            }
        }
    }

    // MARK: - Spacing

    enum Space {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    // MARK: - Radii

    enum Radius {
        static let sm: CGFloat   = 8
        static let md: CGFloat   = 14
        static let lg: CGFloat   = 20
        static let xl: CGFloat   = 28   // CardDataEntry, Tab
        static let card: CGFloat = 56   // outer card
        static let pill: CGFloat = 100
    }
}

// MARK: - Color(hex:) helper

extension SwiftUI.Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >>  8) & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
