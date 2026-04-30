import SwiftUI
import SwiftData

@main
struct GioielliApp: App {
    var body: some Scene {
        WindowGroup {
            SessionListView()
        }
        .modelContainer(for: [CastingSession.self, Lavorazione.self])
    }
}
