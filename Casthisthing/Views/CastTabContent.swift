import SwiftUI

struct CastTabContent: View {
    @Bindable var session: CastingSession

    var body: some View {
        VStack(spacing: 16) {
            DSCardDataEntry(step: 1, label: "Peso cera",     unit: "g",
                            value: $session.waxWeight,        state: stepState(1))
            DSCardDataEntry(step: 2, label: "Argento puro",  unit: "g",
                            value: $session.silverNeeded,     state: stepState(2))
            DSCardDataEntry(step: 3, label: "Costo argento", unit: "€",
                            value: $session.silverCost,       state: stepState(3))
            DSCardDataEntry(step: 4, label: "Costo fusione", unit: "€",
                            value: $session.castingCost,      state: stepState(4))
        }
    }

    private func stepState(_ step: Int) -> DSStepState {
        if session.currentStep > step || session.isComplete { return .done }
        if session.currentStep == step                       { return .active }
        return .locked
    }
}
