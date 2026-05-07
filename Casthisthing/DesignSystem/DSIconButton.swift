import SwiftUI

/// Bottone icona circolare — Figma node 15:114
/// 32×32pt, bordo 0.8px onDisabled, icona 19.2pt
struct DSIconButton: View {
    let icon: DSIcon
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            icon.view(size: 19.2, color: DS.Color.primary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(DS.Color.general)
                        .overlay(
                            Circle()
                                .strokeBorder(DS.Color.onDisabled, lineWidth: 0.8)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DSIconButton(icon: .dotsThree, action: {})
        .padding()
        .background(DS.Color.canvas)
        .registerFonts()
}
