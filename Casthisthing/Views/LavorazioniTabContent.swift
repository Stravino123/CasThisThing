import SwiftUI

/// Tab "Pezzi" — griglia 2 colonne di DSCardWork
/// Figma node 12:165 — per ora mock, logica reale da implementare
struct LavorazioniTabContent: View {
    var body: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: DS.Space.md), GridItem(.flexible())],
            spacing: DS.Space.md   // 16pt sia colonne che righe
        ) {
            // Mock items — sostituire con dati reali
            DSCardWork(content: .item(name: "Lavorazione 1", price: "2 €",  photoData: nil))
            DSCardWork(content: .item(name: "Lavorazione 2", price: "12 €", photoData: nil))
            DSCardWork(content: .addNew)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
