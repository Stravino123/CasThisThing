import SwiftUI
import SwiftData

/// Tab "Pezzi" — griglia 2 colonne di DSCardWork collegata ai dati reali.
/// Figma node 12:165
struct LavorazioniTabContent: View {
    @Bindable var session: CastingSession
    @Environment(\.modelContext) private var context

    @State private var showAdd = false
    @State private var editingLav: Lavorazione?

    private var soldCount: Int { session.lavorazioni.filter { $0.margin != nil }.count }

    var body: some View {
        VStack(spacing: DS.Space.md) {
            HStack(spacing: DS.Space.md) {
                summaryCard(
                    title: "Spesa totale",
                    value: Format.euros(session.totalCost),
                    valueColor: session.totalCost != nil ? DS.Color.text : DS.Color.textSub,
                    caption: session.totalCost != nil ? "argento + fusione" : "completa il cast"
                )
                summaryCard(
                    title: "Guadagno",
                    value: Format.euros(session.totalRevenue),
                    valueColor: session.totalRevenue.map { $0 >= 0 ? .green : .red } ?? DS.Color.textSub,
                    caption: soldCount == 0 ? "nessun pezzo venduto"
                        : soldCount == 1 ? "1 pezzo venduto" : "\(soldCount) pezzi venduti"
                )
            }

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: DS.Space.md), GridItem(.flexible())],
                spacing: DS.Space.md
            ) {
                ForEach(session.sortedLavorazioni) { lav in
                    DSCardWork(
                        content: .item(
                            name: lav.displayName,
                            badge: lav.silverWeight.map { Format.grams($0) },
                            photoData: lav.photoData
                        ),
                        onTap: { editingLav = lav }
                    )
                }
                DSCardWork(content: .addNew, onTap: { showAdd = true })
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .sheet(isPresented: $showAdd) {
            LavorazioneFormView(session: session, lavorazione: nil)
        }
        .sheet(item: $editingLav) { lav in
            LavorazioneFormView(session: session, lavorazione: lav)
        }
    }

    private func summaryCard(title: String, value: String, valueColor: Color, caption: String) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            Text(title)
                .font(DS.Font.excon(size: 12, weight: 500))
                .foregroundStyle(DS.Color.textSub)
                .tracking(-0.24)
            Text(value)
                .font(DS.Font.excon(size: 20, weight: 700).monospacedDigit())
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(caption)
                .font(DS.Font.excon(size: 11, weight: 500))
                .foregroundStyle(DS.Color.textSub)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.md)
        .background(RoundedRectangle(cornerRadius: DS.Radius.xl).fill(DS.Color.general))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.xl).stroke(DS.Color.borderGeneral, lineWidth: 1))
    }
}
