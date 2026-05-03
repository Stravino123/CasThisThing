import SwiftUI

// Single source of truth for all visual constants.
// Use DS.* everywhere — never hardcode colors, radii or spacing in views.

enum DS {

    // MARK: - Colors
    // Source: alias.json exported from Figma (Global + alias collections)
    // Update here whenever aliases change in Figma.

    enum Color {
        // Canvas — app background (← color1/200)
        static let canvas          = SwiftUI.Color(hex: "#FFF5F7")

        // Primary (← color1/1100)
        static let primary         = SwiftUI.Color(hex: "#FF006E")
        static let onPrimary       = SwiftUI.Color(hex: "#FFFFFF")  // ← color1/100
        static let primaryLight    = SwiftUI.Color(hex: "#FFF5F7")  // ← color1/200
        static let onPrimaryLight  = SwiftUI.Color(hex: "#BC004E")  // ← color1/1400

        // Secondary (← color4/700)
        static let secondary       = SwiftUI.Color(hex: "#8FC1CB")
        static let onSecondary     = SwiftUI.Color(hex: "#FFFFFF")  // ← color4/100

        // Borders
        static let borderGeneral   = SwiftUI.Color(hex: "#FDDAE0")  // ← color1/400
        static let borderDisabled  = SwiftUI.Color(hex: "#E2E2E2")  // ← neutral/400

        // General / surface
        static let general         = SwiftUI.Color(hex: "#FFFFFF")  // white
        static let disabled        = SwiftUI.Color(hex: "#F8F8F8")  // ← neutral/200
        static let onDisabled      = SwiftUI.Color(hex: "#B9B9B9")  // ← neutral/700

        // MARK: - Component semantics (usati dai componenti DS)
        // Mappati sugli alias Figma — aggiornare quando gli alias cambiano
        static let bg           = canvas
        static let surface      = disabled
        static let surfaceAlt   = SwiftUI.Color(hex: "#F1F1F1")
        static let accent       = primary
        static let accentDim    = primaryLight
        static let text1        = SwiftUI.Color(hex: "#1B1B1B")     // near-black su canvas chiaro
        static let text2        = text1.opacity(0.55)
        static let text3        = text1.opacity(0.28)
        static let border1      = borderGeneral
        static let border2      = borderGeneral.opacity(0.6)
        static let border3      = borderGeneral.opacity(0.3)
        static let stepDoneFill = primary
        static let stepDoneText = onPrimary
    }

    // MARK: - Typography
    // Uses Excon Variable — registered at app launch via FontLoader in CasthisthingApp.swift

    enum Font {
        static let logo    = excon(size: 14, weight: 700)   // bold monospaced feel
        static let title   = excon(size: 20, weight: 700)
        static let body    = excon(size: 15, weight: 400)
        static let label   = excon(size: 13, weight: 500)
        static let caption = excon(size: 11, weight: 400)
        static let mono    = SwiftUI.Font.system(size: 15).monospacedDigit() // keep mono digits
        static let monoSm  = SwiftUI.Font.system(size: 13).monospacedDigit()

        /// Create an Excon font at any size and weight (100–900).
        static func excon(size: CGFloat, weight: Int = 400) -> SwiftUI.Font {
            .custom("Excon-Variable", size: size)
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
