import SwiftUI

// MARK: - Step state

enum StepState { case done, active, locked }

// MARK: - Timeline

struct CastTabContent: View {
    @Bindable var session: CastingSession

    var body: some View {
        VStack(spacing: 0) {
            StepCard(step: 1, label: "Peso cera",     unit: "g",
                     value: $session.waxWeight,        state: stepState(1))
            connector(filled: session.currentStep > 1)
            StepCard(step: 2, label: "Argento puro",  unit: "g",
                     value: $session.silverNeeded,     state: stepState(2))
            connector(filled: session.currentStep > 2)
            StepCard(step: 3, label: "Costo argento", unit: "€",
                     value: $session.silverCost,       state: stepState(3))
            connector(filled: session.currentStep > 3)
            StepCard(step: 4, label: "Costo fusione", unit: "€",
                     value: $session.castingCost,      state: stepState(4))
        }
    }

    private func connector(filled: Bool) -> some View {
        Rectangle()
            .frame(width: 1, height: 18)
            .foregroundStyle(filled ? AppTheme.borderActive : AppTheme.borderLocked)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 28)
    }

    private func stepState(_ step: Int) -> StepState {
        if session.currentStep > step || session.isComplete { return .done }
        if session.currentStep == step                       { return .active }
        return .locked
    }
}

// MARK: - StepCard

private struct StepCard: View {
    let step: Int
    let label: String
    let unit: String
    @Binding var value: Double?
    let state: StepState

    @State private var isExpanded = false
    @State private var text: String = ""
    @FocusState private var focused: Bool

    private static let fmt: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 4
        f.locale = .current
        return f
    }()

    var body: some View {
        Group {
            switch state {
            case .done:
                doneCard
            case .active:
                activeCard
            case .locked:
                lockedCard
            }
        }
        .onAppear {
            if let v = value {
                text = StepCard.fmt.string(from: NSNumber(value: v)) ?? ""
            }
        }
    }

    // MARK: Done

    private var doneCard: some View {
        HStack(spacing: 12) {
            stepBadge(done: true)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.subheadline).foregroundStyle(Color.black)
            }
            Spacer()
            if let v = value {
                Text(formattedValue(v))
                    .font(.subheadline.monospacedDigit().weight(.semibold))
                    .foregroundStyle(Color.black)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.textPrimary)
        )
    }

    // MARK: Active

    private var activeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                stepBadge(done: false)
                Text(label).font(.subheadline).foregroundStyle(AppTheme.textPrimary)
                Spacer()
                if !isExpanded, let v = value {
                    Text(formattedValue(v))
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(AppTheme.textSec)
                }
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTer)
            }
            if isExpanded {
                HStack {
                    TextField("0", text: $text)
                        .decimalKeyboard()
                        .multilineTextAlignment(.trailing)
                        .focused($focused)
                        .foregroundStyle(AppTheme.textPrimary)
                        .font(.title3.monospacedDigit())
                    Text(unit).foregroundStyle(AppTheme.textSec)
                }
                .padding(.leading, 36)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 1.5, dash: [5])
                )
                .foregroundStyle(AppTheme.borderDash)
                .background(
                    RoundedRectangle(cornerRadius: 12).fill(AppTheme.cardBgAlt)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
            if isExpanded { focused = true }
        }
        .onChange(of: text) { _, newVal in
            value = StepCard.fmt.number(from: newVal)?.doubleValue
                ?? Double(newVal.replacingOccurrences(of: ",", with: "."))
        }
    }

    // MARK: Locked

    private var lockedCard: some View {
        HStack(spacing: 12) {
            stepBadge(done: false)
            Text(label).font(.subheadline).foregroundStyle(AppTheme.textTer)
            Spacer()
            Image(systemName: "lock")
                .font(.caption)
                .foregroundStyle(AppTheme.textTer)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(AppTheme.borderLocked, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 12).fill(AppTheme.cardBg))
        )
    }

    // MARK: Helpers

    private func stepBadge(done: Bool) -> some View {
        ZStack {
            Circle()
                .frame(width: 24, height: 24)
                .foregroundStyle(done ? Color.black.opacity(0.15) : AppTheme.cardBg)
            if done {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.black)
            } else {
                Text("\(step)")
                    .font(.system(size: 11))
                    .foregroundStyle(state == .active ? AppTheme.textPrimary : AppTheme.textTer)
            }
        }
    }

    private func formattedValue(_ v: Double) -> String {
        let s = StepCard.fmt.string(from: NSNumber(value: v)) ?? "\(v)"
        return "\(s) \(unit)"
    }
}
