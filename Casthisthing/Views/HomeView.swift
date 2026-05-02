import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \CastingSession.date, order: .reverse) private var sessions: [CastingSession]

    @State private var showPrevious = false
    @State private var showCatalog = false

    private var currentSession: CastingSession? {
        sessions.first { !$0.isComplete }
    }

    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Logo area
                HStack {
                    Text("CASTHISTHING")
                        .font(DS.Font.logo)
                        .tracking(3)
                        .foregroundStyle(DS.Color.text1)
                        .onLongPressGesture { showCatalog = true }
                    Spacer()
                    Button {
                        addSession()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(AppTheme.cardBg)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)

                // Main content
                if let session = currentSession {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(AppTheme.accent)
                            Text("Current cast")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppTheme.textSec)
                                .textCase(.uppercase)
                                .tracking(1)
                        }
                        .padding(.horizontal, 24)

                        ScrollView {
                            CastCardView(session: session)
                                .padding(.horizontal, 0)
                        }
                        .scrollBounceBehavior(.basedOnSize)
                    }
                } else {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "drop")
                            .font(.system(size: 48))
                            .foregroundStyle(AppTheme.textTer)
                        Text("Nessuna sessione in corso")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textSec)
                        Button("Nuova sessione") { addSession() }
                            .buttonStyle(CapsuleButtonStyle())
                    }
                    Spacer()
                }

                Spacer()

                // Previous casts button
                Button("Previous casts") { showPrevious = true }
                    .buttonStyle(CapsuleButtonStyle())
                    .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showPrevious) {
            PreviousCastsView()
        }
        .sheet(isPresented: $showCatalog) {
            ComponentCatalogView()
        }
    }

    private func addSession() {
        let s = CastingSession(title: "Nuova sessione", date: .now)
        context.insert(s)
        try? context.save()
    }
}
