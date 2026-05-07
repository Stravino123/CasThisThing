import SwiftUI
import SwiftData

/// Tab "Pezzi" — griglia 2 colonne di DSCardWork collegata ai dati reali.
/// Figma node 12:165
struct LavorazioniTabContent: View {
    @Bindable var session: CastingSession
    @Environment(\.modelContext) private var context

    @State private var showAdd = false
    @State private var editingLav: Lavorazione?

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: DS.Space.md), GridItem(.flexible())],
            spacing: DS.Space.md
        ) {
            ForEach(session.lavorazioni) { lav in
                DSCardWork(
                    content: .item(
                        name: lav.label,
                        badge: lav.silverWeight.map { Format.grams($0) },
                        photoData: lav.photoData
                    ),
                    onTap: { editingLav = lav }
                )
            }
            DSCardWork(content: .addNew, onTap: { showAdd = true })
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .sheet(isPresented: $showAdd) {
            LavorazioneFormView(session: session, lavorazione: nil)
        }
        .sheet(item: $editingLav) { lav in
            LavorazioneFormView(session: session, lavorazione: lav)
        }
    }
}
