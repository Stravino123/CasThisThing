import SwiftUI

// MARK: - StepState (shared across CastTabContent + DSCardDataEntry)
enum StepState { case done, active, locked }

/// CardDataEntry — card a 3 stati per gli step della sessione.
/// Corrisponde al componente Figma "CardDataEntry" (file WNXOBpVH9ySn8CvXRc0DbR, node 7:18).
struct DSCardDataEntry: View {
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
            case .done:   filledCard
            case .active: defaultCard
            case .locked: disabledCard
            }
        }
        .onAppear {
            if let v = value {
                text = DSCardDataEntry.fmt.string(from: NSNumber(value: v)) ?? ""
            }
        }
    }

    // MARK: - Filled (done) — bg primaryLight, bordo solid borderGeneral

    private var filledCard: some View {
        HStack(spacing: 16) {
            stepDSIcon.view(size: 24, color: DS.Color.primary)
            VStack(alignment: .leading, spacing: 4) {
                if let v = value {
                    Text(formattedValue(v))
                        .font(DS.Font.excon(size: 16, weight: 500))
                        .foregroundStyle(DS.Color.primary)
                }
                Text(label)
                    .font(DS.Font.excon(size: 12, weight: 500))
                    .foregroundStyle(DS.Color.textSub)
                    .tracking(-0.24)
            }
            Spacer()
        }
        .padding(DS.Space.md)
        .frame(minHeight: 80)
        .background(RoundedRectangle(cornerRadius: DS.Radius.xl).fill(DS.Color.primaryLight))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.xl).stroke(DS.Color.borderGeneral, lineWidth: 1))
    }

    // MARK: - Default (active) — bg white, bordo dashed primary

    private var defaultCard: some View {
        HStack(spacing: 16) {
            DSIcon.plus.view(size: 24, color: DS.Color.primary)
            VStack(alignment: .leading, spacing: 4) {
                Text("Aggiungi")
                    .font(DS.Font.excon(size: 14, weight: 500))
                    .foregroundStyle(DS.Color.primary)
                Text(label)
                    .font(DS.Font.excon(size: 12, weight: 500))
                    .foregroundStyle(DS.Color.textSub)
            }
            Spacer()
            if isExpanded {
                HStack(spacing: 4) {
                    TextField("0", text: $text)
                        .decimalKeyboard()
                        .multilineTextAlignment(.trailing)
                        .focused($focused)
                        .foregroundStyle(DS.Color.text1)
                        .font(DS.Font.excon(size: 20, weight: 500).monospacedDigit())
                        .fixedSize()
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Conferma") {
                                    focused = false
                                }
                                .font(DS.Font.excon(size: 16, weight: 600))
                                .foregroundStyle(DS.Color.primary)
                            }
                        }
                    Text(unit)
                        .foregroundStyle(DS.Color.textSub)
                        .font(DS.Font.excon(size: 14, weight: 400))
                }
            }
        }
        .padding(DS.Space.md)
        .frame(minHeight: 80)
        .background(RoundedRectangle(cornerRadius: DS.Radius.xl).fill(DS.Color.general))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.xl)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                .foregroundStyle(DS.Color.primary)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            isExpanded = true
            focused = true
        }
        .onChange(of: focused) { isFocused in
            guard !isFocused else { return }
            value = DSCardDataEntry.fmt.number(from: text)?.doubleValue
                ?? Double(text.replacingOccurrences(of: ",", with: "."))
        }
    }

    // MARK: - Disabled (locked) — bg disabled, bordo solid borderDisabled

    private var disabledCard: some View {
        HStack(spacing: 16) {
            DSIcon.lock.view(size: 24, color: DS.Color.textSub)
            Text(label)
                .font(DS.Font.excon(size: 14, weight: 500))
                .foregroundStyle(DS.Color.textSub)
            Spacer()
        }
        .padding(DS.Space.md)
        .frame(minHeight: 80)
        .background(RoundedRectangle(cornerRadius: DS.Radius.xl).fill(DS.Color.disabled))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.xl).stroke(DS.Color.borderDisabled, lineWidth: 1))
    }

    // MARK: - Helpers

    private var stepDSIcon: DSIcon {
        switch step {
        case 1:  .barbell
        case 2:  .dropHalf
        case 3:  .piggyBank
        default: .wallet
        }
    }

    private func formattedValue(_ v: Double) -> String {
        let s = DSCardDataEntry.fmt.string(from: NSNumber(value: v)) ?? "\(v)"
        return "\(s) \(unit)"
    }
}

// MARK: - Preview

#Preview("3 stati") {
    VStack(spacing: 12) {
        DSCardDataEntry(step: 1, label: "Peso cera",     unit: "g", value: .constant(12.5),  state: .done)
        DSCardDataEntry(step: 2, label: "Argento puro",  unit: "g", value: .constant(nil),   state: .active)
        DSCardDataEntry(step: 3, label: "Costo argento", unit: "€", value: .constant(nil),   state: .locked)
        DSCardDataEntry(step: 4, label: "Costo fusione", unit: "€", value: .constant(nil),   state: .locked)
    }
    .padding()
    .background(DS.Color.canvas)
    .registerFonts()
}
