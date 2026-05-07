import SwiftUI

// MARK: - DSStepState
// Canonical definition — usata da DSStepBadge, DSCardDataEntry, CastTabContent.

enum DSStepState { case done, active, locked }

// MARK: - DSStepBadge

/// Circular badge showing step number, checkmark (done), or lock (locked).
struct DSStepBadge: View {
    let step: Int
    let state: DSStepState

    private let size: CGFloat = 28

    var body: some View {
        ZStack {
            Circle()
                .fill(fill)
                .frame(width: size, height: size)

            switch state {
            case .done:
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(DS.Color.stepDoneText)
            case .active:
                Text("\(step)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DS.Color.text1)
            case .locked:
                Image(systemName: "lock.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(DS.Color.text3)
            }
        }
    }

    private var fill: Color {
        switch state {
        case .done:   return DS.Color.stepDoneFill
        case .active: return DS.Color.border2
        case .locked: return DS.Color.surface
        }
    }
}

// MARK: - DSConnector

/// Vertical line connecting two step badges in a timeline.
struct DSConnector: View {
    let filled: Bool
    let height: CGFloat

    init(filled: Bool, height: CGFloat = 22) {
        self.filled = filled
        self.height = height
    }

    var body: some View {
        Rectangle()
            .frame(width: 1.5, height: height)
            .foregroundStyle(filled ? DS.Color.border1 : DS.Color.border3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 13)  // aligns with badge center
    }
}

// MARK: - Preview

#Preview("DSStepBadge + DSConnector") {
    VStack(alignment: .leading, spacing: 0) {
        DSStepBadge(step: 1, state: .done)
        DSConnector(filled: true)
        DSStepBadge(step: 2, state: .active)
        DSConnector(filled: false)
        DSStepBadge(step: 3, state: .locked)
        DSConnector(filled: false)
        DSStepBadge(step: 4, state: .locked)
    }
    .padding(DS.Space.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(DS.Color.bg)
    .preferredColorScheme(.dark)
}
