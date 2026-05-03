import SwiftUI

// MARK: - CastCardView

struct CastCardView: View {
    @Bindable var session: CastingSession

    @State private var tab: Int = 0
    @State private var isRenamingTitle = false
    @State private var draftTitle = ""

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack(alignment: .firstTextBaseline) {
                Text(session.title)
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                Spacer()
                Button {
                    draftTitle = session.title
                    isRenamingTitle = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(AppTheme.textSec)
                }
            }

            // Tab control (Figma node 9:109)
            DSTab(labels: ["Cast", "Pezzi"], selection: $tab)

            // Tab content
            Group {
                if tab == 0 {
                    CastTabContent(session: session)
                } else {
                    LavorazioniTabContent(session: session)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: tab)
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
        .alert("Rinomina sessione", isPresented: $isRenamingTitle) {
            TextField("Titolo", text: $draftTitle)
            Button("Salva") {
                let t = draftTitle.trimmingCharacters(in: .whitespaces)
                if !t.isEmpty { session.title = t }
            }
            Button("Annulla", role: .cancel) {}
        }
    }
}
