import SwiftUI

// Single source of truth for all visual constants.
// Use DS.* everywhere — never hardcode colors, radii or spacing in views.

enum DS {

    // MARK: - Colors

    enum Color {
        /// App background — near-black
        static let bg        = SwiftUI.Color(hex: "#0E0E12")
        /// Default card surface
        static let surface   = SwiftUI.Color(hex: "#18181F")
        /// Slightly lighter surface (active step, hover states)
        static let surfaceAlt = SwiftUI.Color(hex: "#202029")

        /// Gold/sand accent (costs, highlights)
        static let accent    = SwiftUI.Color(hex: "#D4B87A")
        static let accentDim = accent.opacity(0.20)

        // Text hierarchy
        static let text1 = SwiftUI.Color.white                    // primary
        static let text2 = SwiftUI.Color.white.opacity(0.55)      // secondary
        static let text3 = SwiftUI.Color.white.opacity(0.28)      // tertiary / disabled

        // Borders
        static let border1 = SwiftUI.Color.white.opacity(0.75)    // strong (done step)
        static let border2 = SwiftUI.Color.white.opacity(0.30)    // dashed (active step)
        static let border3 = SwiftUI.Color.white.opacity(0.10)    // subtle (locked step)

        // Step-done fill — white card
        static let stepDoneFill   = SwiftUI.Color.white
        static let stepDoneText   = SwiftUI.Color.black
    }

    // MARK: - Typography

    enum Font {
        static let logo    = SwiftUI.Font.system(size: 14, weight: .bold, design: .monospaced)
        static let title   = SwiftUI.Font.system(size: 20, weight: .bold)
        static let body    = SwiftUI.Font.system(size: 15, weight: .regular)
        static let label   = SwiftUI.Font.system(size: 13, weight: .medium)
        static let caption = SwiftUI.Font.system(size: 11, weight: .regular)
        static let mono    = SwiftUI.Font.system(size: 15, weight: .regular).monospacedDigit()
        static let monoSm  = SwiftUI.Font.system(size: 13, weight: .regular).monospacedDigit()
    }

    // MARK: - Spacing

    enum Space {
        static let xs: CGFloat  = 4
        static let sm: CGFloat  = 8
        static let md: CGFloat  = 16
        static let lg: CGFloat  = 24
        static let xl: CGFloat  = 32
    }

    // MARK: - Radii

    enum Radius {
        static let sm: CGFloat  = 8
        static let md: CGFloat  = 14
        static let lg: CGFloat  = 20
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
