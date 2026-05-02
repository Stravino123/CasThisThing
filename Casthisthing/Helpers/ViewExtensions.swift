import SwiftUI

extension View {
    @ViewBuilder
    func decimalKeyboard() -> some View {
        #if os(iOS)
        self.keyboardType(.decimalPad)
        #else
        self
        #endif
    }
}

// MARK: - CapsuleButtonStyle

struct CapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundStyle(AppTheme.textPrimary)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    Capsule().fill(AppTheme.cardBg)
                    Capsule().strokeBorder(AppTheme.borderDash, lineWidth: 1)
                }
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
