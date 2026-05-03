import SwiftUI
import SwiftData
import CoreText

@main
struct CasthisthingApp: App {

    init() {
        FontLoader.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [CastingSession.self, Lavorazione.self])
    }
}

// MARK: - Font registration

private enum FontLoader {
    static func registerFonts() {
        let fontNames = ["Excon-Variable"]
        for name in fontNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                print("⚠️ Font not found in bundle: \(name).ttf")
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
