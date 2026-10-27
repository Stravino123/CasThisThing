import SwiftUI

/// Card spesa extra — usata nella lista "Spese e guadagni".
/// Stesso layout di DSCardSession: descrizione + data, poi importo.
struct DSCardSpesaExtra: View {
    let descrizione: String
    let data: Date
    let importo: Double

    var body: some View {
        HStack(alignment: .center, spacing: DS.Space.md) {
            DSIcon.wallet.view(size: 24, color: DS.Color.textSub)

            VStack(alignment: .leading, spacing: DS.Space.md) {

                // ── Riga 1: descrizione + data ─────────────────────────────────
                HStack(alignment: .firstTextBaseline) {
                    Text(descrizione)
                        .font(DS.Font.excon(size: 16, weight: 700))
                        .foregroundStyle(DS.Color.text)
                        .lineLimit(1)
                    Spacer()
                    Text(data.formatted(date: .abbreviated, time: .omitted))
                        .font(DS.Font.caption)
                        .foregroundStyle(DS.Color.textSub)
                }

                // ── Riga 2: etichetta / importo ────────────────────────────────
                HStack(alignment: .lastTextBaseline) {
                    Text("Spesa extra")
                        .font(DS.Font.caption)
                        .foregroundStyle(DS.Color.textSub)
                    Spacer()
                    Text(Format.euros(importo))
                        .font(DS.Font.excon(size: 20, weight: 700).monospacedDigit())
                        .foregroundStyle(DS.Color.primary)
                }
            }
        }
        .padding(DS.Space.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

// MARK: - Preview

#Preview("Spese extra") {
    VStack(spacing: DS.Space.sm) {
        DSCardSpesaExtra(descrizione: "Crogiolo", data: .now, importo: 25.50)
        DSCardSpesaExtra(descrizione: "Spedizione", data: .now, importo: 12)
    }
    .padding(DS.Space.md)
    .background(DS.Color.canvas)
    .registerFonts()
}
