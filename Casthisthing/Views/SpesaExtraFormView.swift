import SwiftUI
import SwiftData

struct SpesaExtraFormView: View {
    var spesa: SpesaExtra?   // nil = new

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var descrizione: String = ""
    @State private var importoText: String = ""
    @State private var data: Date = .now

    private var isEditing: Bool { spesa != nil }

    private var parsedImporto: Double? {
        Format.decimal.number(from: importoText)?.doubleValue
            ?? Double(importoText.replacingOccurrences(of: ",", with: "."))
    }

    private var canSave: Bool {
        !descrizione.trimmingCharacters(in: .whitespaces).isEmpty && (parsedImporto ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Descrizione (es. crogiolo, spedizione)", text: $descrizione)
                    HStack {
                        Text("Importo")
                        Spacer()
                        TextField("0", text: $importoText)
                            .decimalKeyboard()
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("€").foregroundStyle(.secondary)
                    }
                    DatePicker("Data", selection: $data, displayedComponents: .date)
                } footer: {
                    Text("La spesa si somma alla spesa totale e riduce il guadagno.")
                }

                if isEditing {
                    Section {
                        Button("Elimina spesa", role: .destructive) {
                            if let spesa { context.delete(spesa) }
                            try? context.save()
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Modifica spesa" : "Nuova spesa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") { save() }
                        .disabled(!canSave)
                }
            }
            .onAppear { populateFields() }
        }
    }

    private func populateFields() {
        guard let spesa else { return }
        descrizione = spesa.descrizione
        importoText = Format.decimal.string(from: NSNumber(value: spesa.importo)) ?? ""
        data = spesa.data
    }

    private func save() {
        guard let importo = parsedImporto else { return }
        let nome = descrizione.trimmingCharacters(in: .whitespaces)
        if let spesa {
            spesa.descrizione = nome
            spesa.importo = importo
            spesa.data = data
        } else {
            context.insert(SpesaExtra(descrizione: nome, importo: importo, data: data))
        }
        try? context.save()
        dismiss()
    }
}
