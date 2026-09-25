import SwiftUI

/// CardDataEntry — card a 3 stati per gli step della sessione.
/// Corrisponde al componente Figma "CardDataEntry" (file WNXOBpVH9ySn8CvXRc0DbR, node 7:18).
struct DSCardDataEntry: View {
    let step: Int
    let label: String
    let unit: String
    @Binding var value: Double?
    let state: DSStepState

    @State private var isExpanded = false
    @State private var text: String = ""
    @FocusState private var focused: Bool

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
                text = Format.decimal.string(from: NSNumber(value: v)) ?? ""
            }
        }
        // Salva il valore quando la tastiera viene chiusa (qualunque stato)
        .onChange(of: focused) {
            guard !focused else { return }
            value = Format.decimal.number(from: text)?.doubleValue
                ?? Double(text.replacingOccurrences(of: ",", with: "."))
            isExpanded = false
        }
    }

    // MARK: - Filled (done) — bg primaryLight, bordo solid borderGeneral
    // Tap → riapre la modifica inline

    private var filledCard: some View {
        HStack(spacing: 16) {
            stepIcon.view(size: 24, color: DS.Color.primary)
            VStack(alignment: .leading, spacing: 4) {
                if !isExpanded, let v = value {
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
                                Button("Conferma") { focused = false }
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
        .cardStyle(fill: DS.Color.primaryLight, border: DS.Color.borderGeneral)
        .contentShape(Rectangle())
        .onTapGesture {
            text = value.flatMap { Format.decimal.string(from: NSNumber(value: $0)) } ?? ""
            isExpanded = true
            focused   = true
        }
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
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.xl)
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
            .foregroundStyle(DS.Color.primary))
        .contentShape(Rectangle())
        .onTapGesture {
            text       = value.flatMap { Format.decimal.string(from: NSNumber(value: $0)) } ?? ""
            isExpanded = true
            focused    = true
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
        .cardStyle(fill: DS.Color.disabled, border: DS.Color.borderDisabled)
    }

    // MARK: - Helpers

    private var stepIcon: DSIcon {
        switch step {
        case 1:  .candle
        case 2:  .circle
        default: .coin
        }
    }

    private func formattedValue(_ v: Double) -> String {
        let s = Format.decimal.string(from: NSNumber(value: v)) ?? "\(v)"
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
