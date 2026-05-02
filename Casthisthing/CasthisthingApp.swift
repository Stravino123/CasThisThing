import SwiftUI
import SwiftData

@main
struct CasthisthingApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [CastingSession.self, Lavorazione.self])
    }
}
