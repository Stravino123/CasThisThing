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
        VStack(spacing: 0) {
            // ── Header ──────────────────────────────────────────────────────
            // Logo TBD — black bar, extends behind status bar
            Color.black
                .ignoresSafeArea(edges: .top)
                .frame(height: 72)
                .overlay(
                    // Long-press hidden shortcut → DS catalog (dev only)
                    Color.clear.contentShape(Rectangle())
                        .onLongPressGesture { showCatalog = true }
                )

            // ── Content ──────────────────────────────────────────────────────
            Group {
                if let session = currentSession {
                    CastCardView(session: session)
                        .padding(24)
                } else {
                    // Empty state — TBD
                    Button("Nuova sessione") { addSession() }
                        .buttonStyle(DSButtonStyle(.primary))
                        .padding(24)
                    Spacer()
                }
            }
            .ignoresSafeArea(.keyboard)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DS.Color.canvas.ignoresSafeArea())
        }
        .ignoresSafeArea(.keyboard)
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
