import SwiftUI
import SwiftData

struct LavorazioniTabContent: View {
    @Bindable var session: CastingSession
    @Environment(\.modelContext) private var context
    @State private var editingLav: Lavorazione? = nil
    @State private var showingAdd = false

    var body: some View {
        VStack(spacing: 8) {
            if session.lavorazioni.isEmpty {
                Text("Nessuna lavorazione")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTer)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                ForEach(session.lavorazioni) { lav in
                    LavRow(lav: lav, sessionComplete: session.isComplete)
                        .contentShape(Rectangle())
                        .onTapGesture { editingLav = lav }
                }
            }
            Button {
                showingAdd = true
            } label: {
                Label("Aggiungi lavorazione", systemImage: "plus.circle")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
            }
        }
        .sheet(isPresented: $showingAdd) {
            LavorazioneFormView(session: session, lavorazione: nil)
        }
        .sheet(item: $editingLav) { lav in
            LavorazioneFormView(session: session, lavorazione: lav)
        }
    }
}

// MARK: - LavRow

private struct LavRow: View {
    let lav: Lavorazione
    let sessionComplete: Bool
    @State private var thumbnail: UIImage?

    var body: some View {
        HStack(spacing: 12) {
            if let img = thumbnail {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.cardBgAlt)
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.textTer)
                    }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(lav.label)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textPrimary)
                if let w = lav.silverWeight {
                    Text(Format.grams(w))
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSec)
                } else {
                    Text("argento — da pesare")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textTer)
                }
            }
            Spacer()
            if sessionComplete {
                Text(Format.euros(lav.cost))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(lav.cost != nil ? AppTheme.textPrimary : AppTheme.textTer)
            } else {
                Text("— €")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textTer)
            }
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(AppTheme.textTer)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(AppTheme.cardBgAlt)
        )
        .onAppear {
            if thumbnail == nil, let data = lav.photoData {
                thumbnail = UIImage(data: data)
            }
        }
    }
}
