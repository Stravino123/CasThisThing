import SwiftUI
import SwiftData

@main
struct CasthisthingApp: App {
    var body: some Scene {
        WindowGroup {
            SessionListView()
        }
        .modelContainer(for: [CastingSession.self, Lavorazione.self])
    }
}
