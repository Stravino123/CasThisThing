import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct LavorazioneFormView: View {
    let session: CastingSession
    var lavorazione: Lavorazione?   // nil = new

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var label: String = ""
    @State private var silverWeightText: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoImage: UIImage?

    private var isEditing: Bool { lavorazione != nil }

    private var canSave: Bool {
        !label.trimmingCharacters(in: .whitespaces).isEmpty
        && parseWeight(silverWeightText) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Foto") {
                    if let img = photoImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .clipped()
                    }
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label(photoImage == nil ? "Aggiungi foto" : "Cambia foto",
                              systemImage: photoImage == nil ? "photo.badge.plus" : "photo")
                    }
                    if photoImage != nil {
                        Button("Rimuovi foto", role: .destructive) {
                            photoImage = nil
                            selectedPhotoItem = nil
                        }
                    }
                }

                Section {
                    TextField("Nome (es. anello per mamma)", text: $label)
                } header: {
                    Text("Nome")
                }

                Section {
                    HStack {
                        Text("Peso argento")
                        Spacer()
                        TextField("0", text: $silverWeightText)
                            .decimalKeyboard()
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g").foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Argento")
                }

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
                        .disabled(!canSave)
                }
            }
            .onAppear { populateFields() }
            .onChange(of: selectedPhotoItem) {
                guard let newItem = selectedPhotoItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        photoImage = UIImage(data: data)
                    }
                }
            }
        }
    }

    private func populateFields() {
        guard let lav = lavorazione else { return }
        label = lav.label
        if let w = lav.silverWeight {
            silverWeightText = Format.grams.string(from: NSNumber(value: w)) ?? ""
        }
        if let data = lav.photoData {
            photoImage = UIImage(data: data)
        }
    }

    private func parseWeight(_ text: String) -> Double? {
        Format.grams.number(from: text)?.doubleValue
    }

    private func save() {
        let silver = parseWeight(silverWeightText)

        if let lav = lavorazione {
            lav.label       = label.trimmingCharacters(in: .whitespaces)
            lav.silverWeight = silver
            lav.photoData   = photoImage.flatMap { $0.jpegData(compressionQuality: 0.8) }
        } else {
            let lav = Lavorazione(label: label.trimmingCharacters(in: .whitespaces), session: session)
            lav.silverWeight = silver
            lav.photoData   = photoImage.flatMap { $0.jpegData(compressionQuality: 0.8) }
            context.insert(lav)
        }
        try? context.save()
        dismiss()
    }
}

