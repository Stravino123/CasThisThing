import SwiftUI

// MARK: - DSTooltip
/// Checklist prerequisiti per procedere con il calcolo — Figma node 13:208
/// Mostra ogni item con cerchio vuoto (non fatto) o cerchio rosa + ✓ (fatto).
/// Singolo item della checklist prerequisiti.
struct DSTooltipItem {
    let label: String
    let isDone: Bool
}

struct DSTooltip: View {

    let items: [DSTooltipItem]

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.lg) {
            Text("Requisiti")
                .font(DS.Font.excon(size: 14, weight: 700))
                .foregroundStyle(.white)
            ForEach(items.indices, id: \.self) { i in
                HStack(spacing: DS.Space.md) {
                    circleIcon(done: items[i].isDone)
                    Text(items[i].label)
                        .font(DS.Font.excon(size: 12, weight: 500))
                        .foregroundStyle(.white)
                        .tracking(-0.24)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.xl)
                .fill(DS.Color.tooltipBg)
        )
        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 2)
    }

    @ViewBuilder
    private func circleIcon(done: Bool) -> some View {
        ZStack {
            if done {
                Circle()
                    .fill(DS.Color.primary)
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            } else {
                Circle()
                    .strokeBorder(DS.Color.textSub, lineWidth: 0.833)
            }
        }
        .frame(width: 20, height: 20)
    }
}

// MARK: - Preview

#Preview("nessun todo fatto") {
    VStack {
        DSTooltip(items: [
            DSTooltipItem(label: "Cast inserito",        isDone: false),
            DSTooltipItem(label: "Lavorazioni aggiunte", isDone: false)
        ])
        .padding()
    }
    .background(DS.Color.canvas)
    .registerFonts()
}

#Preview("cast fatto") {
    VStack {
        DSTooltip(items: [
            DSTooltipItem(label: "Cast inserito",        isDone: true),
            DSTooltipItem(label: "Lavorazioni aggiunte", isDone: false)
        ])
        .padding()
    }
    .background(DS.Color.canvas)
    .registerFonts()
}
