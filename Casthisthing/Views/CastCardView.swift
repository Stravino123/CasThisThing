import SwiftUI

// MARK: - CastCardView

/// Main session card — Figma node 11:166
/// Outer card: white bg + borderGeneral 1px border + radius.card (56pt) + padding 32pt
/// Sections gap: 32pt
struct CastCardView: View {
    @Bindable var session: CastingSession

    @State private var tab: Int = 0
    @State private var isRenamingTitle = false
    @State private var draftTitle = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {

            // Title
            HStack(alignment: .firstTextBaseline) {
                Text(session.title)
                    .font(DS.Font.excon(size: 24, weight: 700))
                    .foregroundStyle(DS.Color.text)
                    .lineLimit(1)
                Spacer()
                Button {
                    draftTitle = session.title
                    isRenamingTitle = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(DS.Color.textSub)
                }
            }

            // Tab — Figma node 9:109
            DSTab(labels: ["Cast", "Pezzi"], selection: $tab)

            // Tab content — card heights fixed, wrapper expands
            Group {
                if tab == 0 {
                    CastTabContent(session: session)
                } else {
                    LavorazioniTabContent(session: session)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: tab)

            Spacer() // fills remaining space, pushes button to bottom

            // CTA button (placeholder — logic TBD)
            Button("Calcola costo pezzi") { }
                .buttonStyle(DSButtonStyle(.primary))
        }
        .frame(maxHeight: .infinity)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.card)
                .fill(DS.Color.general)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.card)
                        .stroke(DS.Color.borderGeneral, lineWidth: 1)
                )
        )
        .alert("Rinomina sessione", isPresented: $isRenamingTitle) {
            TextField("Titolo", text: $draftTitle)
            Button("Salva") {
                let t = draftTitle.trimmingCharacters(in: .whitespaces)
                if !t.isEmpty { session.title = t }
            }
            Button("Annulla", role: .cancel) {}
        }
    }
}
