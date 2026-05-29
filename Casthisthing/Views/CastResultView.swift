import SwiftUI
import SwiftData
import UIKit

// MARK: - CastResultView
/// Schermata risultati calcolo — presentata come sheet da CastCardView.
/// Mostra il breakdown dei costi cast e il costo proporzionale per ogni lavorazione.
struct CastResultView: View {
    @Bindable var session: CastingSession
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Space.md) {
                    castCostCard
                    if !session.lavorazioni.isEmpty {
                        pezziCard
                    }
                    if let revenue = session.totalRevenue {
                        ricavoCard(revenue: revenue)
                    }
                }
                .padding(DS.Space.lg)
            }
            .background(DS.Color.canvas.ignoresSafeArea())
            .navigationTitle(session.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { dismiss() }
                        .font(DS.Font.label)
                }
            }

            // ── Nuova sessione ─────────────────────────────────────────────
            Button("Nuova sessione") { nuovaSessione() }
                .buttonStyle(DSButtonStyle(.primary))
                .padding(DS.Space.lg)
        }
    }

    // MARK: - Costi cast

    private var castCostCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Costi cast")
                .font(DS.Font.excon(size: 12, weight: 500))
                .foregroundStyle(DS.Color.textSub)
                .tracking(-0.24)
                .padding(.bottom, DS.Space.sm)

            Divider().overlay(DS.Color.borderGeneral)

            costRow("Argento (incl. IVA)", Format.euros(session.silverCost))
                .padding(.vertical, DS.Space.sm)
            Divider().overlay(DS.Color.borderGeneral)
            costRow("Fusione", Format.euros(session.castingCost))
                .padding(.vertical, DS.Space.sm)
            Divider().overlay(DS.Color.borderGeneral)

            HStack {
                Text("Totale")
                    .font(DS.Font.excon(size: 15, weight: 700))
                    .foregroundStyle(DS.Color.text)
                Spacer()
                Text(Format.euros(session.totalCost))
                    .font(DS.Font.excon(size: 15, weight: 700))
                    .foregroundStyle(DS.Color.primary)
            }
            .padding(.top, DS.Space.sm)
        }
        .padding(DS.Space.md)
        .cardStyle()
    }

    // MARK: - Costo per pezzo

    private var pezziCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Costo per pezzo")
                    .font(DS.Font.excon(size: 12, weight: 500))
                    .foregroundStyle(DS.Color.textSub)
                    .tracking(-0.24)
                Spacer()
                if session.totalSilverWeight > 0 {
                    Text(Format.grams(session.totalSilverWeight) + " tot.")
                        .font(DS.Font.caption)
                        .foregroundStyle(DS.Color.textSub)
                }
            }
            .padding(.bottom, DS.Space.sm)

            ForEach(session.lavorazioni) { lav in
                Divider().overlay(DS.Color.borderGeneral)
                LavResultRow(lav: lav)
                    .padding(.vertical, DS.Space.sm)
            }
        }
        .padding(DS.Space.md)
        .cardStyle()
    }

    // MARK: - Ricavi

    private func ricavoCard(revenue: Double) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Margine per pezzo")
                .font(DS.Font.excon(size: 12, weight: 500))
                .foregroundStyle(DS.Color.textSub)
                .tracking(-0.24)
                .padding(.bottom, DS.Space.sm)

            ForEach(session.lavorazioni.filter { $0.margin != nil }) { lav in
                Divider().overlay(DS.Color.borderGeneral)
                costRow(lav.label, Format.euros(lav.margin))
                    .padding(.vertical, DS.Space.sm)
            }

            Divider().overlay(DS.Color.borderGeneral)

            HStack {
                Text("Margine totale")
                    .font(DS.Font.excon(size: 15, weight: 700))
                    .foregroundStyle(DS.Color.text)
                Spacer()
                Text(Format.euros(revenue))
                    .font(DS.Font.excon(size: 15, weight: 700))
                    .foregroundStyle(revenue >= 0 ? DS.Color.primary : .red)
            }
            .padding(.top, DS.Space.sm)
        }
        .padding(DS.Space.md)
        .cardStyle()
    }

    // MARK: - Helpers

    private func costRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(DS.Font.label)
                .foregroundStyle(DS.Color.text)
            Spacer()
            Text(value)
                .font(DS.Font.monoSm)
                .foregroundStyle(DS.Color.textSub)
        }
    }

    private func nuovaSessione() {
        let count = (try? context.fetchCount(FetchDescriptor<CastingSession>())) ?? 0
        let s = CastingSession(title: "Cast #\(count + 1)", date: .now)
        context.insert(s)
        try? context.save()
        dismiss()
    }
}

// MARK: - Riga lavorazione con thumbnail

private struct LavResultRow: View {
    let lav: Lavorazione
    @State private var thumbnail: UIImage?
    @State private var showLightbox = false

    var body: some View {
        HStack(alignment: .center, spacing: DS.Space.sm) {
            // Thumbnail
            if let img = thumbnail {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    .onTapGesture { showLightbox = true }
                    .fullScreenCover(isPresented: $showLightbox) {
                        LightboxView(image: img)
                    }
            } else {
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .fill(DS.Color.disabled)
                    .frame(width: 44, height: 44)
                    .overlay(
                        DSIcon.sparkle.view(size: 18, color: DS.Color.textSub)
                    )
            }

            // Label + peso
            VStack(alignment: .leading, spacing: 2) {
                Text(lav.label)
                    .font(DS.Font.label)
                    .foregroundStyle(DS.Color.text)
                if let w = lav.silverWeight {
                    Text(Format.grams(w))
                        .font(DS.Font.caption)
                        .foregroundStyle(DS.Color.textSub)
                }
            }

            Spacer()

            // Costo
            Text(Format.euros(lav.cost))
                .font(DS.Font.excon(size: 15, weight: 600).monospacedDigit())
                .foregroundStyle(lav.cost != nil ? DS.Color.primary : DS.Color.textSub)
        }
        .onAppear {
            if thumbnail == nil, let data = lav.photoData {
                thumbnail = UIImage(data: data)
            }
        }
    }
}

// MARK: - Lightbox

private struct LightboxView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(DS.Space.md)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(DS.Space.lg)
            }
        }
        .onTapGesture { dismiss() }
    }
}
