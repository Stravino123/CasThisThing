import SwiftUI
import SwiftData
import UIKit

struct SessionDetailView: View {
    @Bindable var session: CastingSession
    @Environment(\.modelContext) private var context

    @State private var showingAddLavorazione = false
    @State private var editingLavorazione: Lavorazione? = nil

    var body: some View {
        Form {
            workflowSection
            lavorazioniSection
            if session.isComplete, let total = session.totalCost {
                costSummarySection(total: total)
            }
        }
        .navigationTitle(session.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .sheet(isPresented: $showingAddLavorazione) {
            LavorazioneFormView(session: session, lavorazione: nil)
        }
        .sheet(item: $editingLavorazione) { lav in
            LavorazioneFormView(session: session, lavorazione: lav)
        }
    }

    // MARK: - Workflow section (4 steps)

    private var workflowSection: some View {
        Section("Workflow") {
            stepRow(
                step: 1, label: "Peso cera",
                subtitle: "Prima della visita in lab",
                value: Format.grams(session.waxWeight),
                isFilled: session.waxWeight != nil,
                isEditable: true
            ) {
                DoubleFieldRow(label: "Peso cera (g)", value: $session.waxWeight, unit: "g")
            }
            stepRow(
                step: 2, label: "Argento puro necessario",
                subtitle: "Dopo la 1ª visita",
                value: Format.grams(session.silverNeeded),
                isFilled: session.silverNeeded != nil,
                isEditable: session.waxWeight != nil
            ) {
                DoubleFieldRow(label: "Argento necessario (g)", value: $session.silverNeeded, unit: "g")
            }
            stepRow(
                step: 3, label: "Costo argento",
                subtitle: "Dopo l'acquisto (incl. IVA)",
                value: Format.euros(session.silverCost),
                isFilled: session.silverCost != nil,
                isEditable: session.silverNeeded != nil
            ) {
                DoubleFieldRow(label: "Costo argento (€)", value: $session.silverCost, unit: "€")
            }
            stepRow(
                step: 4, label: "Costo fusione",
                subtitle: "Dopo la 2ª visita",
                value: Format.euros(session.castingCost),
                isFilled: session.castingCost != nil,
                isEditable: session.silverCost != nil
            ) {
                DoubleFieldRow(label: "Costo fusione (€)", value: $session.castingCost, unit: "€")
            }
        }
    }

    @ViewBuilder
    private func stepRow<Content: View>(
        step: Int,
        label: String,
        subtitle: String,
        value: String,
        isFilled: Bool,
        isEditable: Bool,
        @ViewBuilder editContent: @escaping () -> Content
    ) -> some View {
        if isEditable {
            DisclosureGroup {
                editContent()
            } label: {
                StepRowLabel(step: step, label: label, subtitle: subtitle, value: value, isFilled: isFilled)
            }
        } else {
            StepRowLabel(step: step, label: label, subtitle: subtitle, value: value, isFilled: isFilled)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Lavorazioni section

    private var lavorazioniSection: some View {
        Section {
            ForEach(session.lavorazioni) { lav in
                Button { editingLavorazione = lav } label: {
                    LavorazioneRow(lav: lav, sessionComplete: session.isComplete)
                }
                .foregroundStyle(.primary)
            }
            .onDelete { offsets in
                for i in offsets { context.delete(session.lavorazioni[i]) }
            }

            Button {
                showingAddLavorazione = true
            } label: {
                Label("Aggiungi lavorazione", systemImage: "plus.circle")
            }
        } header: {
            HStack {
                Text("Lavorazioni (\(session.lavorazioni.count))")
                Spacer()
                if session.totalSilverWeight > 0 {
                    Text(Format.grams(session.totalSilverWeight) + " argento")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(nil)
                }
            }
        }
    }

    // MARK: - Cost summary

    private func costSummarySection(total: Double) -> some View {
        Section {
            HStack {
                Text("Argento (incl. IVA)")
                Spacer()
                Text(Format.euros(session.silverCost))
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Fusione")
                Spacer()
                Text(Format.euros(session.castingCost))
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Totale").fontWeight(.semibold)
                Spacer()
                Text(Format.euros(total)).fontWeight(.semibold)
            }
            if let revenue = session.totalRevenue {
                HStack {
                    Text("Margine totale").fontWeight(.semibold)
                    Spacer()
                    Text(Format.euros(revenue)).fontWeight(.semibold)
                        .foregroundStyle(.green)
                }
            }
        } header: {
            Text("Costo totale")
        }
    }
}

// MARK: - Supporting views

private struct StepRowLabel: View {
    let step: Int
    let label: String
    let subtitle: String
    let value: String
    let isFilled: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: isFilled ? [] : [4]))
                    .frame(width: 24, height: 24)
                if isFilled {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                } else {
                    Text("\(step)")
                        .font(.system(size: 12))
                }
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(label).font(.subheadline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(value)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(isFilled ? .primary : .tertiary)
        }
    }
}

private struct LavorazioneRow: View {
    let lav: Lavorazione
    let sessionComplete: Bool
    @State private var thumbnail: UIImage?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(lav.label).font(.subheadline)
                if let w = lav.silverWeight {
                    Text(Format.grams(w))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("argento — da pesare")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()
            if sessionComplete {
                Text(Format.euros(lav.cost))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(lav.cost != nil ? .primary : .tertiary)
            } else {
                Text("— €")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
            if let img = thumbnail {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .onAppear {
            if thumbnail == nil, let data = lav.photoData {
                thumbnail = UIImage(data: data)
            }
        }
    }
}

// MARK: - Inline double entry

private struct DoubleFieldRow: View {
    let label: String
    @Binding var value: Double?
    let unit: String

    @State private var text: String = ""
    @FocusState private var focused: Bool

    private static let inputFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 4
        f.locale = Locale.current
        return f
    }()

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0", text: $text)
                .decimalKeyboard()
                .multilineTextAlignment(.trailing)
                .focused($focused)
                .frame(width: 100)
                #if os(iOS)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Fine") { focused = false }
                    }
                }
                #endif
            Text(unit).foregroundStyle(.secondary)
        }
        .onAppear {
            if let v = value { text = DoubleFieldRow.inputFormatter.string(from: NSNumber(value: v)) ?? "" }
        }
        .onChange(of: text) { _, newVal in
            value = Double(newVal.replacingOccurrences(of: ",", with: "."))
        }
    }
}
