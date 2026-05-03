import SwiftUI
import SwiftData

struct PreviousCastsView: View {
    @Query(sort: \CastingSession.date, order: .reverse) private var allSessions: [CastingSession]
    @Environment(\.dismiss) private var dismiss

    private var completed: [CastingSession] {
        allSessions.filter { $0.isComplete }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()
                Group {
                    if completed.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.largeTitle)
                                .foregroundStyle(AppTheme.textTer)
                            Text("Nessuna sessione completata")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textTer)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(completed) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                PreviousCastRow(session: session)
                            }
                            .listRowBackground(AppTheme.cardBg)
                            .listRowSeparatorTint(AppTheme.borderLocked)
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Previous casts")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { dismiss() }
                        .foregroundStyle(AppTheme.textSec)
                }
            }
        }
    }
}

// MARK: - Row

private struct PreviousCastRow: View {
    let session: CastingSession

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(session.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(session.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(AppTheme.textTer)
            }
            Spacer()
            if let cost = session.totalCost {
                Text(Format.euros(cost))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(AppTheme.accent)
            }
        }
        .padding(.vertical, 4)
    }
}
