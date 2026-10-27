import SwiftUI
import SwiftData

/// Ricevuta che spacchetta "Spesa totale" e "Guadagno" — aperta in sheet
/// toccando una delle due card riepilogo in "Spese e guadagni".
struct SpeseReceiptView: View {
    let completed: [CastingSession]
    let speseExtra: [SpesaExtra]

    @Environment(\.dismiss) private var dismiss

    // MARK: - Calcoli (stessa logica di SpeseGuadagniView)

    private var totalCasts: Double { completed.compactMap(\.totalCost).reduce(0, +) }
    private var totalExtra: Double { speseExtra.map(\.importo).reduce(0, +) }
    private var totalSpend: Double { totalCasts + totalExtra }

    /// Pezzi venduti con margine calcolabile, raggruppati per cast.
    private var soldByCast: [(cast: CastingSession, pieces: [Lavorazione])] {
        completed.compactMap { cast in
            let pieces = cast.sortedLavorazioni.filter { $0.margin != nil }
            return pieces.isEmpty ? nil : (cast, pieces)
        }
    }
    private var totalMargins: Double {
        completed.compactMap(\.totalRevenue).reduce(0, +)
    }
    /// Pezzi segnati come venduti ma senza costo (manca il peso): esclusi dal guadagno.
    private var soldWithoutCost: Int {
        completed.reduce(0) { $0 + $1.lavorazioni.filter { $0.isSold && $0.margin == nil }.count }
    }
    private var profit: Double { totalMargins - totalExtra }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Space.lg) {
                    spendReceipt
                    profitReceipt
                }
                .padding(DS.Space.md)
            }
            .background(DS.Color.canvas.ignoresSafeArea())
            .navigationTitle("Ricevuta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Chiudi") { dismiss() }
                }
            }
        }
    }

    // MARK: - Spesa totale

    private var spendReceipt: some View {
        receiptCard(title: "Spesa totale") {
            sectionLabel("Cast completati")
            if completed.isEmpty {
                emptyLine("Nessun cast completato")
            }
            ForEach(completed) { cast in
                VStack(alignment: .leading, spacing: DS.Space.xs) {
                    line(cast.title, Format.euros(cast.totalCost), bold: true)
                    detailLine("Argento", Format.euros(cast.silverCost))
                    detailLine("Fusione", Format.euros(cast.castingCost))
                }
            }

            divider

            sectionLabel("Spese extra")
            if speseExtra.isEmpty {
                emptyLine("Nessuna spesa extra")
            }
            ForEach(speseExtra) { spesa in
                line(spesa.descrizione, Format.euros(spesa.importo))
            }

            divider

            line("Cast", Format.euros(totalCasts))
            line("Spese extra", Format.euros(totalExtra))
            totalLine("Totale", Format.euros(totalSpend), color: DS.Color.text)
        }
    }

    // MARK: - Guadagno

    private var profitReceipt: some View {
        receiptCard(title: "Guadagno") {
            sectionLabel("Pezzi venduti")
            if soldByCast.isEmpty {
                emptyLine("Nessun pezzo venduto")
            }
            ForEach(soldByCast, id: \.cast.id) { group in
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    Text(group.cast.title)
                        .font(DS.Font.excon(size: 13, weight: 700))
                        .foregroundStyle(DS.Color.text)
                    ForEach(group.pieces) { lav in
                        VStack(alignment: .leading, spacing: DS.Space.xs) {
                            line(lav.displayName, signed(lav.margin))
                            detailLine("Vendita", Format.euros(lav.salePrice))
                            detailLine("Costo", "−" + Format.euros(lav.cost))
                        }
                    }
                }
            }
            if soldWithoutCost > 0 {
                Text(soldWithoutCost == 1
                     ? "1 pezzo venduto è escluso: manca il peso argento, quindi non ha un costo."
                     : "\(soldWithoutCost) pezzi venduti sono esclusi: manca il peso argento, quindi non hanno un costo.")
                    .font(DS.Font.caption)
                    .foregroundStyle(DS.Color.textSub)
            }

            divider

            line("Margine pezzi venduti", signed(totalMargins))
            line("Spese extra", "−" + Format.euros(totalExtra))
            totalLine("Guadagno", signed(profit), color: profit >= 0 ? .green : .red)
        }
    }

    // MARK: - Building blocks

    private func receiptCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            Text(title)
                .font(DS.Font.excon(size: 18, weight: 700))
                .foregroundStyle(DS.Color.text)
            content()
        }
        .padding(DS.Space.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(DS.Font.excon(size: 11, weight: 600))
            .foregroundStyle(DS.Color.textSub)
            .tracking(0.5)
    }

    private func line(_ label: String, _ value: String, bold: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .lineLimit(1)
            Spacer(minLength: DS.Space.sm)
            Text(value)
                .monospacedDigit()
        }
        .font(DS.Font.excon(size: 14, weight: bold ? 600 : 500))
        .foregroundStyle(DS.Color.text)
    }

    private func detailLine(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
            Spacer(minLength: DS.Space.sm)
            Text(value).monospacedDigit()
        }
        .font(DS.Font.caption)
        .foregroundStyle(DS.Color.textSub)
        .padding(.leading, DS.Space.md)
    }

    private func totalLine(_ label: String, _ value: String, color: Color) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(DS.Font.excon(size: 16, weight: 700))
                .foregroundStyle(DS.Color.text)
            Spacer()
            Text(value)
                .font(DS.Font.excon(size: 20, weight: 700).monospacedDigit())
                .foregroundStyle(color)
        }
        .padding(.top, DS.Space.xs)
    }

    private func emptyLine(_ text: String) -> some View {
        Text(text)
            .font(DS.Font.caption)
            .foregroundStyle(DS.Color.textSub)
    }

    /// Linea tratteggiata stile scontrino.
    private var divider: some View {
        Line()
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            .foregroundStyle(DS.Color.borderGeneral)
            .frame(height: 1)
    }

    private func signed(_ value: Double?) -> String {
        guard let value else { return Format.euros(nil) }
        return value > 0 ? "+" + Format.euros(value) : Format.euros(value)
    }
}

private struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.minX, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
    }
}
