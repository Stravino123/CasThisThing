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

    var body: some View {
        Group {
            if completed.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(completed) { session in
                        NavigationLink(destination: SessionDetailView(session: session)) {
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
