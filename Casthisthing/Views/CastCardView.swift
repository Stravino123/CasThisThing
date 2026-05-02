import SwiftUI
import SwiftData

// MARK: - Tab enum

enum CastTab: CaseIterable {
    case cast, lavorazioni

    var label: String {
        switch self {
        case .cast: return "Cast"
        case .lavorazioni: return "Lavorazioni"
        }
    }
}

// MARK: - CastCardView

struct CastCardView: View {
    @Bindable var session: CastingSession
    @Environment(\.modelContext) private var context

    @State private var tab: CastTab = .cast
    @Namespace private var tabNS
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

            // Segmented control
            CastSegmentedControl(selection: $tab, namespace: tabNS)

            // Tab content
            Group {
                if tab == .cast {
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

// MARK: - Segmented control

private struct CastSegmentedControl: View {
    @Binding var selection: CastTab
    var namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 0) {
            ForEach(CastTab.allCases, id: \.self) { tab in
                Button(tab.label) {
                    withAnimation(.spring(duration: 0.25)) { selection = tab }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(selection == tab ? AppTheme.bg : AppTheme.textSec)
                .background {
                    if selection == tab {
                        Capsule()
                            .fill(AppTheme.textPrimary)
                            .matchedGeometryEffect(id: "pill", in: namespace)
                    }
                }
            }
        }
        .padding(3)
        .background(AppTheme.bg.opacity(0.6))
        .clipShape(Capsule())
    }
}
