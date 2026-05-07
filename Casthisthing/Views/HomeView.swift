import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \CastingSession.date, order: .reverse) private var sessions: [CastingSession]

    @State private var showCatalog = false

    // Mostra sempre la sessione più recente, indipendentemente dall'isComplete.
    // L'empty state appare solo quando non esiste ancora alcuna sessione.
    private var currentSession: CastingSession? { sessions.first }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {

                // ── Header ────────────────────────────────────────────────
                // Colori hardcoded (identità brand, non cambiano col tema)
                // bg #171717, bordo bottom #474747 — da Figma node 20:502
                Color(hex: "#171717")
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 72)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color(hex: "#474747"))
                            .frame(height: 1)
                    }
                    .overlay {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 34)
                    }
                    .overlay(
                        Color.clear.contentShape(Rectangle())
                            .onLongPressGesture { showCatalog = true }
                    )

                // ── Content ───────────────────────────────────────────────
                let contentHeight = geo.size.height - 72

                if let session = currentSession {
                    CastCardView(session: session)
                        .padding(DS.Space.lg)
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
        .ignoresSafeArea(.keyboard)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showCatalog) {
            ComponentCatalogView()
        }
    }

    private func addSession() {
        let number = sessions.count + 1
        let s = CastingSession(title: "Cast #\(number)", date: .now)
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
