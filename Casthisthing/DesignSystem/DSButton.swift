import SwiftUI

// MARK: - DSButtonStyle

/// Multi-variant button — primary variant pixel-perfect from Figma node 10:8.
/// Usage: `.buttonStyle(DSButtonStyle(.primary))`
struct DSButtonStyle: ButtonStyle {

    // MARK: - Variant

    enum Variant { case primary, ghost, text, icon }

    // MARK: - Size

    enum Size { case sm, md, lg }

    // MARK: - Init

    let variant: Variant
    let size: Size

    init(_ variant: Variant, size: Size = .md) {
        self.variant = variant
        self.size = size
    }

    @Environment(\.isEnabled) private var isEnabled

    // MARK: - Body

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(labelFont)
            .foregroundStyle(labelColor)
            .padding(padding)
            .background(background)
            .clipShape(Capsule())
            .overlay(border)
            .opacity(configuration.isPressed ? 0.75 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }

    // MARK: - Computed styles

    private var labelFont: SwiftUI.Font {
        switch size {
        case .sm: DS.Font.excon(size: 12, weight: 500)
        case .md: DS.Font.excon(size: 14, weight: 500)
        case .lg: DS.Font.excon(size: 16, weight: 500)
        }
    }

    private var labelColor: Color {
        guard isEnabled else { return DS.Color.onDisabled }
        switch variant {
        case .primary:          return DS.Color.onPrimary
        case .ghost, .text:     return DS.Color.primary
        case .icon:             return DS.Color.primary
        }
    }

    private var padding: EdgeInsets {
        switch (variant, size) {
        case (.icon, _):
            return EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        case (_, .sm):
            return EdgeInsets(top: 8,  leading: 12, bottom: 8,  trailing: 12)
        case (_, .md):
            return EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        case (_, .lg):
            return EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        }
    }

    @ViewBuilder
    private var background: some View {
        if !isEnabled {
            if variant == .text { Color.clear }
            else { DS.Color.disabled }
        } else {
            switch variant {
            case .primary:      DS.Color.primary
            case .ghost, .icon: Color.clear
            case .text:         Color.clear
            }
        }
    }

    @ViewBuilder
    private var border: some View {
        if isEnabled {
            switch variant {
            case .primary:
                Capsule().stroke(DS.Color.primary, lineWidth: 1)
            case .ghost:
                Capsule().stroke(DS.Color.primary, lineWidth: 1)
            case .icon:
                Capsule().stroke(DS.Color.borderGeneral, lineWidth: 1)
            case .text:
                EmptyView()
            }
        } else if variant == .ghost || variant == .icon {
            Capsule().stroke(DS.Color.borderDisabled, lineWidth: 1)
        } else {
            EmptyView()
        }
    }
}

// MARK: - Convenience modifier

extension View {
    func dsPrimaryButton(size: DSButtonStyle.Size = .md) -> some View {
        self.buttonStyle(DSButtonStyle(.primary, size: size))
    }
}

// MARK: - Preview

#Preview("Varianti") {
    VStack(spacing: DS.Space.md) {
        // Primary
        HStack(spacing: DS.Space.md) {
            Button("Primary")  { }.buttonStyle(DSButtonStyle(.primary))
            Button("Primary")  { }.buttonStyle(DSButtonStyle(.primary)).disabled(true)
        }
        // Ghost
        HStack(spacing: DS.Space.md) {
            Button("Ghost")    { }.buttonStyle(DSButtonStyle(.ghost))
            Button("Ghost")    { }.buttonStyle(DSButtonStyle(.ghost)).disabled(true)
        }
        // Text
        HStack(spacing: DS.Space.md) {
            Button("Text")     { }.buttonStyle(DSButtonStyle(.text))
            Button("Text")     { }.buttonStyle(DSButtonStyle(.text)).disabled(true)
        }
        // Icon
        HStack(spacing: DS.Space.md) {
            Button { } label: { Image(systemName: "plus").frame(width: 18, height: 18) }
                .buttonStyle(DSButtonStyle(.icon))
            Button { } label: { Image(systemName: "pencil").frame(width: 18, height: 18) }
                .buttonStyle(DSButtonStyle(.icon))
        }
        // Sizes (ghost)
        HStack(spacing: DS.Space.sm) {
            Button("SM") { }.buttonStyle(DSButtonStyle(.ghost, size: .sm))
            Button("MD") { }.buttonStyle(DSButtonStyle(.ghost, size: .md))
            Button("LG") { }.buttonStyle(DSButtonStyle(.ghost, size: .lg))
        }
    }
    .padding()
    .background(DS.Color.canvas)
    .registerFonts()
}
