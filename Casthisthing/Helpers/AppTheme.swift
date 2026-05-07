import SwiftUI
import Observation

// MARK: - AppTheme

enum AppTheme: String, CaseIterable, Identifiable {
    case magenta = "Magenta"
    case premium = "Premium"

    var id: String { rawValue }

    /// ColorScheme di sistema associato al tema
    var colorScheme: ColorScheme {
        self == .premium ? .dark : .light
    }

    var icon: String {
        self == .magenta ? "paintbrush.fill" : "star.fill"
    }
}

// MARK: - ThemeStore

/// Singleton @Observable — persiste la scelta in UserDefaults.
/// Tutti i componenti DS leggono ThemeStore.shared.current;
/// SwiftUI traccia l'accesso e ri-renderizza automaticamente quando cambia.
@Observable
final class ThemeStore {
    static let shared = ThemeStore()

    var current: AppTheme {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: "casthisthing.theme")
        }
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "casthisthing.theme") ?? ""
        current = AppTheme(rawValue: saved) ?? .magenta
    }
}
