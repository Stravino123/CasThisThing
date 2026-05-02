import SwiftUI

// MARK: - Button variants

enum DSButtonVariant {
    case primary   // filled capsule, accent color
    case ghost     // outlined capsule, white
    case text      // no background, accent color
    case icon      // circle, surface fill
}

// MARK: - DSButtonStyle

struct DSButtonStyle: ButtonStyle {
    let variant: DSButtonVariant
    let size: DSButtonSize

    init(_ variant: DSButtonVariant = .ghost, size: DSButtonSize = .md) {
        self.variant = variant
        self.size = size
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, size.hPad)
            .padding(.vertical, size.vPad)
            .background(background(pressed: configuration.isPressed))
            .opacity(configuration.isPressed ? 0.75 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary: return .black
        case .ghost:   return DS.Color.text1
        case .text:    return DS.Color.accent
        case .icon:    return DS.Color.text1
        }
    }

    @ViewBuilder
    private func background(pressed: Bool) -> some View {
        switch variant {
        case .primary:
            Capsule().fill(DS.Color.accent)
        case .ghost:
            ZStack {
                Capsule().fill(DS.Color.surface)
                Capsule().strokeBorder(DS.Color.border2, lineWidth: 1)
            }
        case .text:
            Color.clear
        case .icon:
            Circle().fill(DS.Color.surface)
        }
    }
}

enum DSButtonSize {
    case sm, md, lg

    var font: Font {
        switch self {
        case .sm: return DS.Font.caption
        case .md: return DS.Font.label
        case .lg: return DS.Font.body
        }
    }
    var hPad: CGFloat {
        switch self { case .sm: return 14; case .md: return 22; case .lg: return 28 }
    }
    var vPad: CGFloat {
        switch self { case .sm: return 7; case .md: return 10; case .lg: return 14 }
    }
}

// MARK: - Preview

#Preview("DSButton variants") {
    VStack(spacing: DS.Space.lg) {
        Button("Primary action") {}
            .buttonStyle(DSButtonStyle(.primary))

        Button("Ghost / outline") {}
            .buttonStyle(DSButtonStyle(.ghost))

        Button("Text link") {}
            .buttonStyle(DSButtonStyle(.text))

        HStack(spacing: DS.Space.md) {
            Button { } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(DSButtonStyle(.icon))

            Button { } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 14))
                    .frame(width: 18, height: 18)
            }
            .buttonStyle(DSButtonStyle(.icon))
        }

        HStack(spacing: DS.Space.md) {
            Button("Small") {}  .buttonStyle(DSButtonStyle(.ghost, size: .sm))
            Button("Medium") {} .buttonStyle(DSButtonStyle(.ghost, size: .md))
            Button("Large") {}  .buttonStyle(DSButtonStyle(.ghost, size: .lg))
        }
    }
    .padding(DS.Space.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(DS.Color.bg)
    .preferredColorScheme(.dark)
}
