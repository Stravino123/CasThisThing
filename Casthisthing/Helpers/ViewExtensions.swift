import SwiftUI

// MARK: - Decimal keyboard

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

// MARK: - Card style

extension View {
    /// Applica il background e il bordo standard delle card DS.
    /// Usare per qualsiasi card con sfondo solido + bordo 1px.
    func cardStyle(
        radius: CGFloat = DS.Radius.xl,
        fill: Color = DS.Color.general,
        border: Color = DS.Color.borderGeneral,
        lineWidth: CGFloat = 1
    ) -> some View {
        self
            .background(RoundedRectangle(cornerRadius: radius).fill(fill))
            .overlay(RoundedRectangle(cornerRadius: radius).stroke(border, lineWidth: lineWidth))
    }
}
