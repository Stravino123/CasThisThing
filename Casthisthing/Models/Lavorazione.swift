import Foundation
import SwiftData

@Model
final class Lavorazione: Identifiable {
    var id: UUID
    var label: String
    var waxWeight: Double?      // entered at step 1 — historical ref only, never in cost calc
    var silverWeight: Double?   // entered after picking up pieces — drives cost calc
    var session: CastingSession

    init(label: String, session: CastingSession) {
        self.id = UUID()
        self.label = label
        self.session = session
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
