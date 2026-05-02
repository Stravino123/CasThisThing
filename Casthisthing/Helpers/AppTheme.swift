import SwiftUI

enum AppTheme {
    // Backgrounds
    static let bg        = Color(red: 0.06, green: 0.06, blue: 0.08)   // ~#0F0F14
    static let cardBg    = Color(red: 0.10, green: 0.10, blue: 0.13)   // ~#1A1A21
    static let cardBgAlt = Color(red: 0.13, green: 0.13, blue: 0.17)   // step attivo

    // Accents
    static let accent    = Color(red: 0.85, green: 0.75, blue: 0.55)   // oro/sabbia
    static let accentDim = accent.opacity(0.25)

    // Text
    static let textPrimary = Color.white
    static let textSec     = Color.white.opacity(0.55)
    static let textTer     = Color.white.opacity(0.30)

    // Borders
    static let borderActive = Color.white.opacity(0.80)
    static let borderDash   = Color.white.opacity(0.35)
    static let borderLocked = Color.white.opacity(0.12)

    // Layout
    static let cardPadding: CGFloat = 20
    static let cardRadius:  CGFloat = 20
}
