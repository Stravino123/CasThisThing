import SwiftUI

/// Tab segmented control — Figma node 9:109
/// Container: white bg + borderGeneral 1px border + radius xl (28pt) + h-40pt
/// Active item:  primaryLight bg + borderPrimary 1px border + radius xl
/// Inactive item: no bg/border, textSub text
struct DSTab: View {
    let labels: [String]
    @Binding var selection: Int
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 0) {
            ForEach(labels.indices, id: \.self) { i in
                Button {
                    withAnimation(.spring(duration: 0.25)) { selection = i }
                } label: {
                    Text(labels[i])
                        .font(DS.Font.excon(size: 14, weight: 500))
                        .foregroundStyle(selection == i ? DS.Color.primary : DS.Color.textSub)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background {
                            if selection == i {
                                RoundedRectangle(cornerRadius: DS.Radius.xl)
                                    .fill(DS.Color.primaryLight)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DS.Radius.xl)
                                            .stroke(DS.Color.borderPrimary, lineWidth: 1)
                                    )
                                    .matchedGeometryEffect(id: "tab-pill", in: ns)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 40)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.xl)
                .fill(DS.Color.general)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.xl)
                        .stroke(DS.Color.borderGeneral, lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview

#Preview("Cast selezionato") {
    DSTab(labels: ["Cast", "Pezzi"], selection: .constant(0))
        .padding()
        .background(DS.Color.canvas)
        .registerFonts()
}

#Preview("Pezzi selezionato") {
    DSTab(labels: ["Cast", "Pezzi"], selection: .constant(1))
        .padding()
        .background(DS.Color.canvas)
        .registerFonts()
}
