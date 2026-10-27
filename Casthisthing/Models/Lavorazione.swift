import Foundation
import SwiftData

@Model
final class Lavorazione: Identifiable {
    var id: UUID
    // Non più mostrato (il nome è ora "#N"); tenuto per non migrare i dati esistenti.
    var label: String
    var createdAt: Date?        // nil solo per lavorazioni create prima della numerazione automatica
    var silverWeight: Double?   // entered after picking up pieces — drives cost calc
    var salePrice: Double?      // prezzo di vendita — opzionale; se presente il pezzo è venduto
    @Attribute(.externalStorage) var photoData: Data?
    var session: CastingSession

    init(session: CastingSession) {
        self.id = UUID()
        self.label = ""
        self.createdAt = .now
        self.session = session
    }

    var isSold: Bool { salePrice != nil }

    var displayName: String {
        let index = session.sortedLavorazioni.firstIndex { $0.id == id } ?? 0
        return "#\(index + 1)"
    }

    /// Margine netto: prezzo di vendita − costo di produzione.
    /// Nil se manca il prezzo di vendita o il costo non è ancora calcolabile.
    var margin: Double? {
        guard let sp = salePrice, let c = cost else { return nil }
        return sp - c
    }

    // Returns nil when any required input is missing or total weight is zero.
    // Formula: (silverWeight / totalSilverWeight) × (silverCost + castingCost)
    var cost: Double? {
        guard
            let w = silverWeight,
            let sc = session.silverCost,
            let cc = session.castingCost
        else { return nil }
        let total = session.totalSilverWeight
        guard total > 0 else { return nil }
        return (w / total) * (sc + cc)
    }
}
