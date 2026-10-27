import SwiftUI
import SwiftData

/// Riepilogo spesa totale e guadagno sui cast completati, più le spese extra
/// aggiunte a mano — accessibile dal menu tre-puntini.
/// Pushato dentro il NavigationStack root dell'app (non crea il suo).
struct SpeseGuadagniView: View {
    // Query senza predicato: filtro in memoria per evitare crash
    // con #Predicate su Optional in SwiftData.
    @Query(sort: \CastingSession.date, order: .reverse)
    private var allSessions: [CastingSession]

    @Query(sort: \SpesaExtra.data, order: .reverse)
    private var speseExtra: [SpesaExtra]

    @Environment(\.modelContext) private var context

    @State private var showNewSpesa = false
    @State private var editingSpesa: SpesaExtra?
    @State private var showReceipt = false

    private var completed: [CastingSession] {
        allSessions.filter { $0.isComplete }
    }

    private var totalExtra: Double { speseExtra.map(\.importo).reduce(0, +) }
    private var totalSpend: Double { completed.compactMap(\.totalCost).reduce(0, +) + totalExtra }
    /// Margini dei pezzi venduti meno le spese extra.
    /// Nil solo se non c'è né un margine né una spesa extra.
    private var totalProfit: Double? {
        let margins = completed.compactMap(\.totalRevenue)
        guard !margins.isEmpty || !speseExtra.isEmpty else { return nil }
        return margins.reduce(0, +) - totalExtra
    }
    private var soldCount: Int {
        completed.reduce(0) { $0 + $1.lavorazioni.filter(\.isSold).count }
    }

    private var spendCaption: String {
        let casts = completed.count == 1 ? "1 cast" : "\(completed.count) cast"
        let extra = speseExtra.count == 1 ? "1 extra" : "\(speseExtra.count) extra"
        return speseExtra.isEmpty ? casts : "\(casts) + \(extra)"
    }

    var body: some View {
        List {
            HStack(spacing: DS.Space.md) {
                Button { showReceipt = true } label: {
                    summaryCard(
                        title: "Spesa totale",
                        value: Format.euros(totalSpend),
                        valueColor: DS.Color.text,
                        caption: spendCaption
                    )
                }
                .buttonStyle(.plain)
                Button { showReceipt = true } label: {
                    summaryCard(
                        title: "Guadagno",
                        value: Format.euros(totalProfit),
                        valueColor: totalProfit.map { $0 >= 0 ? .green : .red } ?? DS.Color.textSub,
                        caption: soldCount == 0 ? "nessun pezzo venduto"
                            : soldCount == 1 ? "1 pezzo venduto" : "\(soldCount) pezzi venduti"
                    )
                }
                .buttonStyle(.plain)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(
                top: DS.Space.sm,
                leading: DS.Space.md,
                bottom: DS.Space.lg,
                trailing: DS.Space.md
            ))

            Section {
                if speseExtra.isEmpty {
                    Text("Nessuna spesa extra. Aggiungi qui attrezzatura, materiali o spedizioni: verranno sommati alla spesa totale.")
                        .font(DS.Font.caption)
                        .foregroundStyle(DS.Color.textSub)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(speseExtra) { spesa in
                        Button { editingSpesa = spesa } label: {
                            DSCardSpesaExtra(
                                descrizione: spesa.descrizione,
                                data: spesa.data,
                                importo: spesa.importo
                            )
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(
                            top: DS.Space.xs,
                            leading: DS.Space.md,
                            bottom: DS.Space.xs,
                            trailing: DS.Space.md
                        ))
                    }
                    .onDelete(perform: deleteSpese)
                }
            } header: {
                Text("Spese extra")
                    .font(DS.Font.excon(size: 13, weight: 600))
                    .foregroundStyle(DS.Color.textSub)
                    .textCase(nil)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        // Bottone sticky in fondo: resta visibile anche con tante spese in lista
        .safeAreaInset(edge: .bottom) {
            Button { showNewSpesa = true } label: {
                HStack(spacing: DS.Space.sm) {
                    DSIcon.plus.view(size: 20, color: DS.Color.onPrimary)
                    Text("Aggiungi spesa extra")
                }
            }
            .buttonStyle(DSButtonStyle(.primary))
            .padding(.horizontal, DS.Space.md)
            .padding(.top, DS.Space.sm)
            .padding(.bottom, DS.Space.md)
            .background(DS.Color.canvas.ignoresSafeArea())
        }
        .background(DS.Color.canvas.ignoresSafeArea())
        .navigationTitle("")
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Spese e guadagni")
                    .font(DS.Font.excon(size: 17, weight: 600))
                    .foregroundStyle(DS.Color.text)
            }
        }
        .sheet(isPresented: $showNewSpesa) {
            SpesaExtraFormView()
        }
        .sheet(item: $editingSpesa) { spesa in
            SpesaExtraFormView(spesa: spesa)
        }
        .sheet(isPresented: $showReceipt) {
            SpeseReceiptView(completed: completed, speseExtra: speseExtra)
        }
    }

    private func deleteSpese(at offsets: IndexSet) {
        offsets.map { speseExtra[$0] }.forEach(context.delete)
        try? context.save()
    }

    // MARK: - Summary card

    private func summaryCard(title: String, value: String, valueColor: Color, caption: String) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.xs) {
            Text(title)
                .font(DS.Font.excon(size: 12, weight: 500))
                .foregroundStyle(DS.Color.textSub)
                .tracking(-0.24)
            Text(value)
                .font(DS.Font.excon(size: 20, weight: 700).monospacedDigit())
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(caption)
                .font(DS.Font.excon(size: 11, weight: 500))
                .foregroundStyle(DS.Color.textSub)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.md)
        .background(RoundedRectangle(cornerRadius: DS.Radius.xl).fill(DS.Color.general))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.xl).stroke(DS.Color.borderGeneral, lineWidth: 1))
    }
}
