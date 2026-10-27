import SwiftUI

/// Etichetta di stato vendita di una lavorazione: "Venduta" (verde) / "Non venduta" (neutra).
struct DSSoldTag: View {
    let isSold: Bool
    /// Testo alternativo (es. "Tutto venduto" sulle card dei cast); nil = "Venduta"/"Non venduta".
    var label: String? = nil

    var body: some View {
        Text(label ?? (isSold ? "Venduta" : "Non venduta"))
            .font(DS.Font.excon(size: 11, weight: 600))
            .foregroundStyle(isSold ? Color.green : DS.Color.textSub)
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule().fill(isSold ? Color.green.opacity(0.15) : DS.Color.disabled)
            )
    }
}

#Preview {
    HStack {
        DSSoldTag(isSold: true)
        DSSoldTag(isSold: false)
        DSSoldTag(isSold: true, label: "Tutto venduto")
    }
    .padding()
    .background(DS.Color.canvas)
    .registerFonts()
}
