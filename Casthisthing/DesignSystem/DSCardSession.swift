import SwiftUI

/// Card sessione precedente — usata nella lista "Cast precedenti".
/// Mostra titolo, data, numero pezzi, peso argento totale e costo totale.
struct DSCardSession: View {
    let title: String
    let date: Date
    let pieceCount: Int
    let totalSilverWeight: Double?
    let totalCost: Double?
    /// true se il cast ha lavorazioni e sono state vendute tutte
    var allSold: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: DS.Space.md) {
            DSIcon.dropHalf.view(size: 24, color: DS.Color.textSub)

            VStack(alignment: .leading, spacing: DS.Space.md) {

                // ── Riga 1: titolo + data ──────────────────────────────────────
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                        .font(DS.Font.excon(size: 16, weight: 700))
                        .foregroundStyle(DS.Color.text)
                        .lineLimit(1)
                    if allSold {
                        DSSoldTag(isSold: true, label: "Tutto venduto")
                    }
                    Spacer()
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(DS.Font.caption)
                        .foregroundStyle(DS.Color.textSub)
                }

                // ── Riga 2: pezzi + peso / costo totale ───────────────────────
                HStack(alignment: .lastTextBaseline) {
                    Text(subtitle)
                        .font(DS.Font.caption)
                        .foregroundStyle(DS.Color.textSub)
                    Spacer()
                    Text(Format.euros(totalCost))
                        .font(DS.Font.excon(size: 20, weight: 700).monospacedDigit())
                        .foregroundStyle(DS.Color.primary)
                }
            }
        }
        .padding(DS.Space.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    // MARK: - Helpers

    private var subtitle: String {
        let pieces = pieceCount == 1 ? "1 pezzo" : "\(pieceCount) pezzi"
        if let w = totalSilverWeight, w > 0 {
            return "\(pieces) · \(Format.grams(w))"
        }
        return pieces
    }
}

// MARK: - Preview

#Preview("Lista sessioni") {
    VStack(spacing: DS.Space.sm) {
        DSCardSession(
            title: "Cast gennaio",
            date: .now,
            pieceCount: 4,
            totalSilverWeight: 18.5,
            totalCost: 142.30,
            allSold: true
        )
        DSCardSession(
            title: "Cast natale — anelli",
            date: Calendar.current.date(byAdding: .month, value: -2, to: .now)!,
            pieceCount: 1,
            totalSilverWeight: 5.2,
            totalCost: 38.00
        )
        DSCardSession(
            title: "Cast senza peso argento",
            date: Calendar.current.date(byAdding: .month, value: -4, to: .now)!,
            pieceCount: 3,
            totalSilverWeight: nil,
            totalCost: 95.00
        )
    }
    .padding(DS.Space.md)
    .background(DS.Color.canvas)
    .registerFonts()
}
