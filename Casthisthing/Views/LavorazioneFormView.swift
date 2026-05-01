import SwiftUI
import SwiftData

struct LavorazioneFormView: View {
    let session: CastingSession
    var lavorazione: Lavorazione?   // nil = new

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var label: String = ""
    @State private var waxWeightText: String = ""
    @State private var silverWeightText: String = ""

    private var isEditing: Bool { lavorazione != nil }

    // Silver weight is editable only once the session has all 4 steps filled.
    // The user enters it after picking up finished pieces from the lab.
    private var silverFieldUnlocked: Bool { session.isComplete }

    var body: some View {
        NavigationStack {
            Form {
                // Phase indicator — shows where we are in the 4-step workflow
                Section {
                    SessionPhaseIndicator(session: session)
                }

                // ① Label + wax weight — entered at step 1, always editable
                Section {
                    TextField("Nome (es. anello per mamma)", text: $label)

                    HStack {
                        Text("Peso cera")
                        Spacer()
                        TextField("0", text: $waxWeightText)
                            .decimalKeyboard()
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g").foregroundStyle(.secondary)
                    }
                } header: {
                    Text("① Cera · \(isEditing ? "modifica" : "adesso")")
                }

                // ② Silver weight — locked until session is complete
                Section {
                    if silverFieldUnlocked {
                        HStack {
                            Text("Peso argento")
                            Spacer()
                            TextField("0", text: $silverWeightText)
                                .decimalKeyboard()
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("g").foregroundStyle(.secondary)
                        }
                    } else {
                        HStack {
                            Text("Peso argento")
                            Spacer()
                            Text("sbloccato dopo step 4")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                            Image(systemName: "lock")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                } header: {
                    Text("② Argento · dopo il ritiro")
                }

                // Cost preview — read-only, shown only when available
                Section {
                    HStack {
                        Text("Costo lavorazione")
                        Spacer()
                        if session.isComplete, let lav = lavorazione, let cost = lav.cost {
                            Text(Format.euros(cost))
                                .fontWeight(.semibold)
                        } else {
                            Text(session.isComplete ? "— € (inserire peso argento)" : "— € (calcolato a step 4)")
                                .foregroundStyle(.tertiary)
                        }
                    }
                } header: {
                    Text("③ ④ · costo proporzionale")
                }

                // Delete — editing only
                if isEditing {
                    Section {
                        Button("Elimina lavorazione", role: .destructive) {
                            if let lav = lavorazione {
                                context.delete(lav)
                            }
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Modifica lavorazione" : "Nuova lavorazione")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") { save() }
                        .disabled(label.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { populateFields() }
        }
    }

    private func populateFields() {
        guard let lav = lavorazione else { return }
        label = lav.label
        if let w = lav.waxWeight {
            waxWeightText = Format.grams.string(from: NSNumber(value: w)) ?? ""
        }
        if let w = lav.silverWeight {
            silverWeightText = Format.grams.string(from: NSNumber(value: w)) ?? ""
        }
    }

    private func parseWeight(_ text: String) -> Double? {
        Format.grams.number(from: text)?.doubleValue
    }

    private func save() {
        let wax = parseWeight(waxWeightText)
        let silver = parseWeight(silverWeightText)

        if let lav = lavorazione {
            lav.label = label.trimmingCharacters(in: .whitespaces)
            lav.waxWeight = wax
            if silverFieldUnlocked { lav.silverWeight = silver }
        } else {
            let lav = Lavorazione(label: label.trimmingCharacters(in: .whitespaces), session: session)
            lav.waxWeight = wax
            if silverFieldUnlocked { lav.silverWeight = silver }
            context.insert(lav)
        }
        dismiss()
    }
}

// MARK: - Phase indicator

private struct SessionPhaseIndicator: View {
    let session: CastingSession

    private let labels = ["Cera", "Ag g", "Ag €", "Fusione"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<4, id: \.self) { i in
                let step = i + 1
                let isDone = session.currentStep > step || session.isComplete
                let isCurrent = session.currentStep == step && !session.isComplete

                HStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .strokeBorder(style: StrokeStyle(
                                lineWidth: 1.2,
                                dash: isDone || isCurrent ? [] : [3]
                            ))
                            .frame(width: 18, height: 18)
                            .foregroundStyle(isDone ? Color.primary : .secondary)
                        if isDone {
                            Image(systemName: "checkmark")
                                .font(.system(size: 9, weight: .bold))
                        } else {
                            Text("\(step)").font(.system(size: 9))
                                .foregroundStyle(isCurrent ? .primary : .tertiary)
                        }
                    }
                    Text(labels[i])
                        .font(.caption2)
                        .foregroundStyle(isDone || isCurrent ? .primary : .tertiary)
                }

                if i < 3 {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(isDone ? Color.primary.opacity(0.3) : Color.secondary.opacity(0.2))
                        .padding(.horizontal, 4)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
