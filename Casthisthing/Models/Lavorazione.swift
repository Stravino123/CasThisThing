import Foundation
import SwiftData

@Model
final class Lavorazione: Identifiable {
    var id: UUID
    var label: String
    var silverWeight: Double?   // entered after picking up pieces — drives cost calc
    var salePrice: Double?      // prezzo di vendita — opzionale
    @Attribute(.externalStorage) var photoData: Data?
    var session: CastingSession

    init(label: String, session: CastingSession) {
        self.id = UUID()
        self.label = label
        self.session = session
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
