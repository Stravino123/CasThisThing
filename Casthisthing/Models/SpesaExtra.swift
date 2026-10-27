import Foundation
import SwiftData

/// Spesa non legata a un cast (es. attrezzatura, spedizioni) — si somma alla spesa totale
/// e si sottrae dal guadagno in "Spese e guadagni".
@Model
final class SpesaExtra: Identifiable {
    var id: UUID
    var descrizione: String
    var importo: Double
    var data: Date

    init(descrizione: String, importo: Double, data: Date = .now) {
        self.id = UUID()
        self.descrizione = descrizione
        self.importo = importo
        self.data = data
    }
}
