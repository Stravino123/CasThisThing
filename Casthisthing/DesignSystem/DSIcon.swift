import SwiftUI

/// Icone esportate da Figma — sempre template per permettere il tinting.
/// Non usare mai SF Symbols come sostituti: esportare sempre dall'originale Figma.
enum DSIcon: String {
    case barbell    = "ic_barbell"
    case dropHalf   = "ic_drop_half"
    case piggyBank  = "ic_piggy_bank"
    case wallet     = "ic_wallet"
    case plus       = "ic_plus"
    case lock       = "ic_lock"
    case sparkle    = "ic_sparkle"

    var image: Image { Image(rawValue) }
}

extension DSIcon {
    func view(size: CGFloat = 24, color: Color = DS.Color.primary) -> some View {
        image
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(color)
    }
}

#Preview {
    HStack(spacing: 16) {
        DSIcon.barbell.view()
        DSIcon.dropHalf.view()
        DSIcon.piggyBank.view()
        DSIcon.wallet.view()
        DSIcon.plus.view(color: DS.Color.primary)
        DSIcon.lock.view(color: DS.Color.textSub)
        DSIcon.sparkle.view(color: DS.Color.primary)
    }
    .padding()
    .background(DS.Color.canvas)
}
