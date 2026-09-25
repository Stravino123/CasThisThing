import SwiftUI
import SwiftData

// MARK: - CastCardView
/// Main session card — Figma node 11:166
/// Outer card: white bg + borderGeneral 1px border + radius.card (56pt) + padding 32pt
/// Sections gap: 32pt (DS.Space.xl)
struct CastCardView: View {
    @Bindable var session: CastingSession
    @Environment(\.modelContext) private var context

    @State private var tab: Int = 0
    @State private var showTooltip = false
    @State private var showResults = false
    @State private var showPreviousCasts = false

    private var castComplete:   Bool { session.isComplete }
    private var hasLavorazioni: Bool { !session.lavorazioni.isEmpty }
    private var canCalculate:   Bool { castComplete && hasLavorazioni }

    var body: some View {
        ZStack {
            // ── Layer 1: contenuto card ────────────────────────────────────
            VStack(alignment: .leading, spacing: DS.Space.xl) {

                // Title
                HStack(alignment: .center) {
                    Text(session.title)
                        .font(DS.Font.excon(size: 24, weight: 700))
                        .foregroundStyle(DS.Color.text)
                        .lineLimit(1)
                    Spacer()
                    Menu {
                        Button { showPreviousCasts = true } label: {
                            Label("Cast precedenti", systemImage: "clock")
                        }
                        Divider()
                        Button {
                            let other = ThemeStore.shared.current == .magenta ? AppTheme.premium : .magenta
                            withAnimation(.easeInOut(duration: 0.3)) {
                                ThemeStore.shared.current = other
                            }
                        } label: {
                            let other = ThemeStore.shared.current == .magenta ? AppTheme.premium : .magenta
                            Label("Tema \(other.rawValue)", systemImage: other.icon)
                        }
                        Divider()
                        Button { resetAll() } label: {
                            Label("Ricomincia sessione", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        DSIconButton(icon: .dotsThree, action: {})
                    }
                    .menuStyle(.automatic)
                }

                // Tab selector — Figma node 9:109
                DSTab(labels: ["Cast", "Lavorazioni"], selection: $tab)

                // Tab content — scrollabile, occupa lo spazio residuo tra tab e CTA
                ScrollView {
                    Group {
                        if tab == 0 {
                            CastTabContent(session: session)
                        } else {
                            LavorazioniTabContent(session: session)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .animation(.easeInOut(duration: 0.2), value: tab)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // CTA — il tooltip fluttua 8pt sopra il bottone come overlay;
                // il dismiss layer (layer 2) cattura i tap ovunque per chiuderlo.
                Button {
                    if canCalculate {
                        showResults = true
                    } else {
                        withAnimation(.spring(duration: 0.2)) { showTooltip.toggle() }
                    }
                } label: {
                    HStack(spacing: DS.Space.sm) {
                        DSIcon.sparkle.view(size: 24, color: DS.Color.onPrimary)
                        Text("Calcola costo pezzi")
                    }
                }
                .buttonStyle(DSButtonStyle(.primary))
                // Tooltip posizionato 8pt sopra il bottone.
                // .overlay(alignment: .bottom) → bottom del tooltip = bottom del bottone
                // offset(y: -(altezza bottone 48 + gap 8)) → bottom del tooltip = top bottone - 8pt
                .overlay(alignment: .bottom) {
                    if showTooltip && !canCalculate {
                        DSTooltip(items: [
                            DSTooltipItem(label: "Informazioni del cast inserite", isDone: castComplete),
                            DSTooltipItem(label: "Almeno una lavorazione aggiunta", isDone: hasLavorazioni)
                        ])
                        .frame(maxWidth: .infinity)
                        .offset(y: -(48 + DS.Space.sm))
                        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .bottom)))
                        .allowsHitTesting(false) // i tap passano al dismiss layer
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // ── Layer 2: dismiss overlay ───────────────────────────────────
            // Appare solo quando il tooltip è visibile.
            // Cattura qualsiasi tap sulla card e chiude il tooltip.
            // Essendo l'ultimo nel ZStack è sopra tutto il contenuto,
            // tranne il tooltip che è non-interattivo (layer 1, allowsHitTesting: false).
            if showTooltip {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.2)) { showTooltip = false }
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DS.Space.xl)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.card)
                .fill(DS.Color.general)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.card)
                        .stroke(DS.Color.borderGeneral, lineWidth: 1)
                )
        )
        // Swipe verso sinistra → cast precedenti. Solo se il gesto è nettamente orizzontale,
        // così non interferisce con lo scroll verticale delle card.
        .simultaneousGesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    let dx = value.translation.width
                    let dy = value.translation.height
                    if dx < -80 && abs(dx) > abs(dy) * 2 {
                        showPreviousCasts = true
                    }
                }
        )
        .sheet(isPresented: $showResults) {
            CastResultView(session: session)
        }
        .navigationDestination(isPresented: $showPreviousCasts) {
            SessionsListView()
        }
    }

    // MARK: - Reset

    private func resetAll() {
        session.waxWeight    = nil
        session.silverNeeded = nil
        session.silverCost   = nil
        session.castingCost  = nil
        session.lavorazioni.forEach { context.delete($0) }
        try? context.save()
    }
}
