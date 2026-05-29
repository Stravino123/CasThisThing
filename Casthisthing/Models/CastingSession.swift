import Foundation
import SwiftData

@Model
final class CastingSession: Identifiable {
    var id: UUID
    var title: String
    var date: Date
    var waxWeight: Double?      // step 1 — historical ref only, never in cost calc
    var silverNeeded: Double?   // step 2 — g
    var silverCost: Double?     // step 3 — €
    var castingCost: Double?    // step 4 — €

    @Relationship(deleteRule: .cascade, inverse: \Lavorazione.session)
    var lavorazioni: [Lavorazione] = []

    init(title: String, date: Date) {
        self.id = UUID()
        self.title = title
        self.date = date
    }

    // The sum is always derived; user never inputs a total.
    var totalSilverWeight: Double {
        lavorazioni.compactMap(\.silverWeight).reduce(0, +)
    }

    // Session is complete only once both cost fields are filled.
    var isComplete: Bool {
        silverCost != nil && castingCost != nil
    }

    var totalCost: Double? {
        guard let sc = silverCost, let cc = castingCost else { return nil }
        return sc + cc
    }

    /// Somma dei prezzi di vendita delle lavorazioni che hanno un prezzo.
    /// Ritorna nil se nessuna lavorazione ha un prezzo di vendita.
    var totalRevenue: Double? {
        let prices = lavorazioni.compactMap(\.salePrice)
        guard !prices.isEmpty else { return nil }
        return prices.reduce(0, +)
    }

    // Drives field unlock logic in the UI (1–4).
    var currentStep: Int {
        if silverCost != nil   { return 4 }
        if silverNeeded != nil { return 3 }
        if waxWeight != nil    { return 2 }
        return 1
    }
}
