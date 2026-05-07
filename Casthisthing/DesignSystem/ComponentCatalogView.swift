import SwiftUI

/// Debug screen — shows all DS components on dark background.
/// Access: long-press the "CASTHISTHING" logo in HomeView (debug builds only).
struct ComponentCatalogView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var segSel = 0
    @Namespace private var segNS

    var body: some View {
        NavigationStack {
            ZStack {
                DS.Color.bg.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: DS.Space.xl) {
                        section("Colors") { colorsSection }
                        section("Typography") { typographySection }
                        section("DSCard") { cardsSection }
                        section("DSButton") { buttonsSection }
                        section("DSSegmentedControl") { segmentedSection }
                        section("DSStepBadge + DSConnector") { stepsSection }
                    }
                    .padding(DS.Space.lg)
                }
            }
            .navigationTitle("Component Catalog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { dismiss() }
                        .foregroundStyle(DS.Color.text2)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Sections

    private var colorsSection: some View {
        let swatches: [(String, Color)] = [
            ("bg",         DS.Color.bg),
            ("surface",    DS.Color.surface),
            ("surfaceAlt", DS.Color.surfaceAlt),
            ("accent",     DS.Color.accent),
            ("text1",      DS.Color.text1),
            ("text2",      DS.Color.text2),
            ("text3",      DS.Color.text3),
            ("border1",    DS.Color.border1),
            ("border2",    DS.Color.border2),
            ("border3",    DS.Color.border3),
        ]
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: DS.Space.sm) {
            ForEach(swatches, id: \.0) { name, color in
                VStack(spacing: DS.Space.xs) {
                    RoundedRectangle(cornerRadius: DS.Radius.sm)
                        .fill(color)
                        .frame(height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.Radius.sm)
                                .strokeBorder(DS.Color.border3, lineWidth: 1)
                        )
                    Text(name)
                        .font(DS.Font.caption)
                        .foregroundStyle(DS.Color.text2)
                }
            }
        }
    }

    private var typographySection: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Group {
                Text("Logo — CASTHISTHING").font(DS.Font.logo)
                Text("Title — Sessione 01").font(DS.Font.title)
                Text("Body — Testo normale").font(DS.Font.body)
                Text("Label — Etichetta").font(DS.Font.label)
                Text("Caption — Nota piccola").font(DS.Font.caption)
                Text("Mono — 247,50 €").font(DS.Font.mono)
                Text("Mono SM — 14,20 g").font(DS.Font.monoSm)
            }
            .foregroundStyle(DS.Color.text1)
        }
    }

    private var cardsSection: some View {
        VStack(spacing: DS.Space.sm) {
            ForEach(
                [(DSCardStyle.default, "Default"),
                 (.outlined, "Outlined"),
                 (.stepDone, "Step Done"),
                 (.stepActive, "Step Active"),
                 (.stepLocked, "Step Locked")],
                id: \.1
            ) { style, label in
                DSCard(style) {
                    HStack {
                        Text(label)
                            .font(DS.Font.label)
                            .foregroundStyle(style == .stepDone ? DS.Color.stepDoneText
                                             : style == .stepLocked ? DS.Color.text3
                                             : DS.Color.text1)
                        Spacer()
                        Text("14,20 g")
                            .font(DS.Font.monoSm)
                            .foregroundStyle(style == .stepDone ? DS.Color.stepDoneText
                                             : style == .stepLocked ? DS.Color.text3
                                             : DS.Color.text2)
                    }
                }
            }
        }
    }

    private var buttonsSection: some View {
        VStack(spacing: DS.Space.md) {
            HStack(spacing: DS.Space.md) {
                Button("Primary")  {} .buttonStyle(DSButtonStyle(.primary))
                Button("Ghost")    {} .buttonStyle(DSButtonStyle(.ghost))
                Button("Text")     {} .buttonStyle(DSButtonStyle(.text))
            }
            HStack(spacing: DS.Space.md) {
                Button { } label: {
                    Image(systemName: "plus").frame(width: 18, height: 18)
                }.buttonStyle(DSButtonStyle(.icon))
                Button { } label: {
                    Image(systemName: "pencil").frame(width: 18, height: 18)
                }.buttonStyle(DSButtonStyle(.icon))
                Button { } label: {
                    Image(systemName: "star").frame(width: 18, height: 18)
                }.buttonStyle(DSButtonStyle(.icon))
            }
            HStack(spacing: DS.Space.sm) {
                Button("SM") {} .buttonStyle(DSButtonStyle(.ghost, size: .sm))
                Button("MD") {} .buttonStyle(DSButtonStyle(.ghost, size: .md))
                Button("LG") {} .buttonStyle(DSButtonStyle(.ghost, size: .lg))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var segmentedSection: some View {
        DSSegmentedControl(
            options: ["Cast", "Lavorazioni"],
            selection: $segSel,
            namespace: segNS
        )
    }

    private var stepsSection: some View {
        HStack(alignment: .top, spacing: DS.Space.xl) {
            // Full timeline
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(zip(
                    [DSStepState.done, .active, .locked, .locked],
                    1...4
                )), id: \.1) { state, step in
                    DSStepBadge(step: step, state: state)
                    if step < 4 { DSConnector(filled: state == .done) }
                }
            }

            // Individual badges
            VStack(alignment: .leading, spacing: DS.Space.sm) {
                HStack(spacing: DS.Space.sm) {
                    DSStepBadge(step: 1, state: .done)
                    Text("Done").font(DS.Font.caption).foregroundStyle(DS.Color.text2)
                }
                HStack(spacing: DS.Space.sm) {
                    DSStepBadge(step: 2, state: .active)
                    Text("Active").font(DS.Font.caption).foregroundStyle(DS.Color.text2)
                }
                HStack(spacing: DS.Space.sm) {
                    DSStepBadge(step: 3, state: .locked)
                    Text("Locked").font(DS.Font.caption).foregroundStyle(DS.Color.text2)
                }
            }
        }
    }

    // MARK: - Helpers

    private func section<Content: View>(_ title: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text(title.uppercased())
                .font(DS.Font.caption)
                .foregroundStyle(DS.Color.text3)
                .tracking(1.5)
            content()
        }
    }
}

// MARK: - Preview

#Preview("Component Catalog") {
    ComponentCatalogView()
}
