import SwiftUI

// MARK: - Card style

enum DSCardStyle {
    case `default`   // dark surface, no border
    case outlined    // dark surface + subtle border
    case stepDone    // white fill, dark text
    case stepActive  // dark surface + dashed border
    case stepLocked  // dark surface + barely-visible border
}

// MARK: - DSCard

/// Generic container that applies the correct surface + border for a given style.
/// Wrap any content inside:
///   DSCard(.stepActive) { ... }
struct DSCard<Content: View>: View {
    let style: DSCardStyle
    let content: () -> Content

    init(_ style: DSCardStyle = .default, @ViewBuilder content: @escaping () -> Content) {
        self.style = style
        self.content = content
    }

    var body: some View {
        content()
            .padding(DS.Space.md)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(border)
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .default, .outlined, .stepActive, .stepLocked:
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .fill(style == .stepActive ? DS.Color.surfaceAlt : DS.Color.surface)
        case .stepDone:
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .fill(DS.Color.stepDoneFill)
        }
    }

    @ViewBuilder
    private var border: some View {
        switch style {
        case .default:
            EmptyView()
        case .outlined:
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .strokeBorder(DS.Color.border3, lineWidth: 1)
        case .stepDone:
            EmptyView()
        case .stepActive:
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                .foregroundStyle(DS.Color.border2)
        case .stepLocked:
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .strokeBorder(DS.Color.border3, lineWidth: 1)
        }
    }
}

// MARK: - Preview

#Preview("DSCard variants") {
    ScrollView {
        VStack(spacing: DS.Space.md) {
            DSCard(.default) {
                cardContent("Default", subtitle: "Dark surface, no border")
            }
            DSCard(.outlined) {
                cardContent("Outlined", subtitle: "Subtle border")
            }
            DSCard(.stepDone) {
                cardContent("Step Done", subtitle: "White fill", textColor: DS.Color.stepDoneText)
            }
            DSCard(.stepActive) {
                cardContent("Step Active", subtitle: "Dashed border")
            }
            DSCard(.stepLocked) {
                cardContent("Step Locked", subtitle: "Barely-visible border", dimmed: true)
            }
        }
        .padding(DS.Space.lg)
    }
    .background(DS.Color.bg)
    .preferredColorScheme(.dark)
}

private func cardContent(
    _ title: String,
    subtitle: String,
    textColor: Color = DS.Color.text1,
    dimmed: Bool = false
) -> some View {
    HStack {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            Text(title)
                .font(DS.Font.label)
                .foregroundStyle(dimmed ? DS.Color.text3 : textColor)
            Text(subtitle)
                .font(DS.Font.caption)
                .foregroundStyle(dimmed ? DS.Color.text3 : DS.Color.text2)
        }
        Spacer()
    }
}
