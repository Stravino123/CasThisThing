import SwiftUI
import SwiftData

/// Elenco dei cast completati — accessibile dal menu tre-puntini.
/// Pushato dentro il NavigationStack root dell'app (non crea il suo).
struct SessionsListView: View {
    // Query senza predicato: filtro in memoria per evitare crash
    // con #Predicate su Optional in SwiftData.
    @Query(sort: \CastingSession.date, order: .reverse)
    private var allSessions: [CastingSession]

    // Stesso query in ordine crescente, usato solo per la rinumerazione
    @Query(sort: \CastingSession.date, order: .forward)
    private var allSessionsAsc: [CastingSession]

    @Environment(\.modelContext) private var context

    private var completed: [CastingSession] {
        allSessions.filter { $0.isComplete }
    }

    private var totalSpend: Double { completed.compactMap(\.totalCost).reduce(0, +) }
    private var totalProfit: Double? {
        let margins = completed.compactMap(\.totalRevenue)
        return margins.isEmpty ? nil : margins.reduce(0, +)
    }
    private var soldCount: Int {
        completed.reduce(0) { $0 + $1.lavorazioni.filter { $0.margin != nil }.count }
    }

    var body: some View {
        Group {
            if completed.isEmpty {
                emptyState
            } else {
                List {
                    HStack(spacing: DS.Space.md) {
                        summaryCard(
                            title: "Spesa totale",
                            value: Format.euros(totalSpend),
                            valueColor: DS.Color.text,
                            caption: completed.count == 1 ? "1 cast completato" : "\(completed.count) cast completati"
                        )
                        summaryCard(
                            title: "Guadagno",
                            value: Format.euros(totalProfit),
                            valueColor: totalProfit.map { $0 >= 0 ? .green : .red } ?? DS.Color.textSub,
                            caption: soldCount == 0 ? "nessun pezzo venduto"
                                : soldCount == 1 ? "1 pezzo venduto" : "\(soldCount) pezzi venduti"
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    // bottom + top della prima card cast (xs) = 24pt di distanza
                    .listRowInsets(EdgeInsets(
                        top: DS.Space.sm,
                        leading: DS.Space.md,
                        bottom: DS.Space.lg - DS.Space.xs,
                        trailing: DS.Space.md
                    ))

                    ForEach(completed) { session in
                        // NavigationLink invisibile dietro la card: nella List evita il chevron di sistema.
                        ZStack {
                            NavigationLink(destination: SessionDetailView(session: session)) { EmptyView() }
                                .opacity(0)
                            DSCardSession(
                                title: session.title,
                                date: session.date,
                                pieceCount: session.lavorazioni.count,
                                totalSilverWeight: session.totalSilverWeight > 0 ? session.totalSilverWeight : nil,
                                totalCost: session.totalCost
                            )
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(
                            top: DS.Space.xs,
                            leading: DS.Space.md,
                            bottom: DS.Space.xs,
                            trailing: DS.Space.md
                        ))
                    }
                    .onDelete(perform: deleteCasts)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(DS.Color.canvas.ignoresSafeArea())
        .navigationTitle("")
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Cast precedenti")
                    .font(DS.Font.excon(size: 17, weight: 600))
                    .foregroundStyle(DS.Color.text)
            }
        }
    }

    // MARK: - Delete + renumber

    private func deleteCasts(at offsets: IndexSet) {
        let idsToDelete = Set(offsets.map { completed[$0].persistentModelID })

        for id in idsToDelete {
            if let s = allSessions.first(where: { $0.persistentModelID == id }) {
                context.delete(s)
            }
        }

        let remaining = allSessionsAsc
            .filter { !idsToDelete.contains($0.persistentModelID) }
        for (i, s) in remaining.enumerated() {
            s.title = "Cast #\(i + 1)"
        }

        try? context.save()
    }

    // MARK: - Summary card

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

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: DS.Space.sm) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(DS.Color.textSub)
            Text("Nessun cast completato")
                .font(DS.Font.body)
                .foregroundStyle(DS.Color.textSub)
            Text("I cast completati appariranno qui")
                .font(DS.Font.caption)
                .foregroundStyle(DS.Color.textSub.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
