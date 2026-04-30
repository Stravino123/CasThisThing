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

    // Drives field unlock logic in the UI (1–4).
    var currentStep: Int {
        if castingCost != nil { return 4 }
        if silverCost != nil  { return 3 }
        if silverNeeded != nil { return 2 }
        return 1
    }
}

// Stub — will be replaced fully in Task 2.
@Model
final class Lavorazione {
    var label: String
    var waxWeight: Double?
    var silverWeight: Double?

    @Relationship var session: CastingSession?

    init(label: String, session: CastingSession?) {
        self.label = label
        self.session = session
    }
}
