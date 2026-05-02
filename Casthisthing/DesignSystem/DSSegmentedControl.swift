import SwiftUI

// MARK: - DSSegmentedControl

/// Animated pill segmented control.
/// Usage:
///   @State private var tab = 0
///   @Namespace private var ns
///   DSSegmentedControl(options: ["Cast", "Lavorazioni"], selection: $tab, namespace: ns)
struct DSSegmentedControl: View {
    let options: [String]
    @Binding var selection: Int
    var namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { i in
                Button(options[i]) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = i
                    }
                }
                .font(DS.Font.label)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Space.sm + 2)
                .foregroundStyle(selection == i ? .black : DS.Color.text2)
                .background {
                    if selection == i {
                        Capsule()
                            .fill(DS.Color.text1)
                            .matchedGeometryEffect(id: "pill", in: namespace)
                    }
                }
            }
        }
        .padding(3)
        .background(DS.Color.bg.opacity(0.8))
        .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview("DSSegmentedControl") {
    struct Demo: View {
        @State private var sel = 0
        @Namespace private var ns
        var body: some View {
            VStack(spacing: DS.Space.xl) {
                DSSegmentedControl(
                    options: ["Cast", "Lavorazioni"],
                    selection: $sel,
                    namespace: ns
                )
                Text("Tab selezionato: \(sel == 0 ? "Cast" : "Lavorazioni")")
                    .font(DS.Font.caption)
                    .foregroundStyle(DS.Color.text2)
            }
            .padding(DS.Space.lg)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DS.Color.bg)
        }
    }
    return Demo().preferredColorScheme(.dark)
}
