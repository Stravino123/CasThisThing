import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct LavorazioneFormView: View {
    let session: CastingSession
    var lavorazione: Lavorazione?   // nil = new

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var silverWeightText: String = ""
    @State private var salePriceText: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoImage: UIImage?
    @State private var weightScan: WeightScan = .idle

    private enum WeightScan: Equatable { case idle, reading, done(ScaleReading) }

    private var isEditing: Bool { lavorazione != nil }

    private var parsedSalePrice: Double? {
        Format.decimal.number(from: salePriceText)?.doubleValue
            ?? Double(salePriceText.replacingOccurrences(of: ",", with: "."))
    }

    private var canSave: Bool {
        parseWeight(silverWeightText) != nil
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
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label("Cambia foto", systemImage: "photo")
                        }
                        Button("Rimuovi foto", role: .destructive) {
                            photoImage = nil
                            selectedPhotoItem = nil
                            weightScan = .idle
                        }
                    } else {
                        photoUploadArea
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                    }
                }

                Section {
                    HStack {
                        Text("Peso argento")
                        Spacer()
                        if weightScan == .reading {
                            ProgressView()
                        }
                        TextField("0", text: $silverWeightText)
                            .decimalKeyboard()
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g").foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Argento")
                } footer: {
                    switch weightScan {
                    case .idle:
                        EmptyView()
                    case .reading:
                        Text("Leggo il peso dalla foto…")
                    case .done(.weight):
                        Text("Peso letto dalla foto della bilancia — controlla che sia corretto.")
                    case .done(.notFound):
                        Text("Non sono riuscito a leggere il peso dalla foto. Inseriscilo a mano.")
                    case .done(.failed(let message)):
                        Text(message)
                    }
                }

                Section {
                    HStack {
                        Text("Prezzo di vendita")
                        Spacer()
                        TextField("—", text: $salePriceText)
                            .decimalKeyboard()
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("€").foregroundStyle(.secondary)
                    }
                    if let salePrice = parsedSalePrice,
                       let cost = lavorazione?.cost {
                        let margin = salePrice - cost
                        HStack {
                            Text("Margine")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(Format.euros(margin))
                                .foregroundStyle(margin >= 0 ? .green : .red)
                                .fontWeight(.semibold)
                        }
                    }
                } header: {
                    Text("Vendita")
                } footer: {
                    Text("Opzionale — inserisci il prezzo solo se hai già venduto il pezzo.")
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
            .navigationTitle(lavorazione?.displayName ?? "#\(session.lavorazioni.count + 1)")
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
                    guard let data = try? await newItem.loadTransferable(type: Data.self),
                          let img = UIImage(data: data) else { return }
                    photoImage = img
                    await readWeight(from: img)
                }
            }
        }
    }

    private func readWeight(from img: UIImage) async {
        weightScan = .reading
        let result = await ScaleReader.readWeight(from: img)
        if case .weight(let w) = result {
            silverWeightText = Format.grams.string(from: NSNumber(value: w)) ?? ""
        }
        weightScan = .done(result)
    }

    private var photoUploadArea: some View {
        VStack(spacing: DS.Space.md) {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                HStack(spacing: DS.Space.sm) {
                    DSIcon.sparkle.view(size: 20, color: DS.Color.onPrimary)
                    Text("Carica foto")
                }
            }
            .buttonStyle(DSButtonStyle(.primary, size: .sm))
            .frame(width: 180)
            Text("Fotografa il pezzo sulla bilancia: l'AI leggerà il peso dal display e lo inserirà per te.")
                .font(DS.Font.excon(size: 12, weight: 500))
                .foregroundStyle(DS.Color.textSub)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Space.lg)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(RoundedRectangle(cornerRadius: DS.Radius.xl).fill(DS.Color.general))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.xl)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                .foregroundStyle(DS.Color.primary)
        )
    }

    private func populateFields() {
        guard let lav = lavorazione else { return }
        if let w = lav.silverWeight {
            silverWeightText = Format.grams.string(from: NSNumber(value: w)) ?? ""
        }
        if let p = lav.salePrice {
            salePriceText = Format.decimal.string(from: NSNumber(value: p)) ?? ""
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

        let salePrice = parsedSalePrice

        if let lav = lavorazione {
            lav.silverWeight = silver
            lav.salePrice    = salePrice
            lav.photoData    = photoImage.flatMap { $0.jpegData(compressionQuality: 0.8) }
        } else {
            let lav = Lavorazione(session: session)
            lav.silverWeight = silver
            lav.salePrice    = salePrice
            lav.photoData    = photoImage.flatMap { $0.jpegData(compressionQuality: 0.8) }
            context.insert(lav)
        }
        try? context.save()
        dismiss()
    }
}

