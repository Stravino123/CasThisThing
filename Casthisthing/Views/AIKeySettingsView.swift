import SwiftUI

struct AIKeySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var key: String = KeychainStore.geminiKey ?? ""
    private let hasSavedKey = KeychainStore.geminiKey != nil

    private var trimmedKey: String { key.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("Incolla qui la chiave API", text: $key)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("Chiave Gemini")
                } footer: {
                    Text("Serve per leggere il peso dalla foto della bilancia. Si crea gratis su Google AI Studio e resta salvata solo su questo telefono.")
                }

                Section {
                    Link(destination: URL(string: "https://aistudio.google.com/apikey")!) {
                        Label("Crea una chiave su Google AI Studio", systemImage: "arrow.up.right.square")
                    }
                }

                if hasSavedKey {
                    Section {
                        Button("Rimuovi chiave", role: .destructive) {
                            KeychainStore.geminiKey = nil
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Chiave AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        KeychainStore.geminiKey = trimmedKey
                        dismiss()
                    }
                    .disabled(trimmedKey.isEmpty)
                }
            }
        }
    }
}
