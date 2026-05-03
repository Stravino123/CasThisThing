import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \CastingSession.date, order: .reverse) private var sessions: [CastingSession]

    @State private var showCatalog = false

    private var currentSession: CastingSession? {
        sessions.first { !$0.isComplete }
    }

    var body: some View {
        // GeometryReader misura l'altezza prima che la tastiera appaia.
        // Le altezze vengono fissate esplicitamente — la tastiera non può
        // spostare nulla. Vedi BEST_PRACTICES.md § Keyboard.
        GeometryReader { geo in
            VStack(spacing: 0) {

                // ── Header ────────────────────────────────────────────────
                Color.black
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 72)
                    .overlay(
                        Color.clear.contentShape(Rectangle())
                            .onLongPressGesture { showCatalog = true }
                    )

                // ── Content ───────────────────────────────────────────────
                let contentHeight = geo.size.height - 72

                if let session = currentSession {
                    CastCardView(session: session)
                        .padding(DS.Space.lg)          // 24pt — margini uguali su tutti i lati
                        .frame(height: contentHeight)
                } else {
                    VStack {
                        Spacer()
                        Button("Nuova sessione") { addSession() }
                            .buttonStyle(DSButtonStyle(.primary))
                            .padding(.horizontal, DS.Space.lg)
                        Spacer()
                    }
                    .frame(height: contentHeight)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(DS.Color.canvas.ignoresSafeArea())
        }
        .ignoresSafeArea(.keyboard)   // sul GeometryReader, non sul VStack interno
        .sheet(isPresented: $showCatalog) {
            ComponentCatalogView()
        }
    }

    private func addSession() {
        let s = CastingSession(title: "Nuova sessione", date: .now)
        context.insert(s)
        try? context.save()
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CastingSession.self, Lavorazione.self, configurations: config)
    let session = CastingSession(title: "Cast in corso", date: .now)
    session.waxWeight = 12.5
    container.mainContext.insert(session)
    return HomeView()
        .modelContainer(container)
        .registerFonts()
}
