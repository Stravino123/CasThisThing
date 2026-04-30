import SwiftUI
import SwiftData

struct SessionListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \CastingSession.date, order: .reverse) private var sessions: [CastingSession]

    @State private var showingNewSession = false

    private var inProgress: [CastingSession] { sessions.filter { !$0.isComplete } }
    private var completed: [CastingSession]  { sessions.filter {  $0.isComplete } }

    var body: some View {
        NavigationStack {
            List {
                if !inProgress.isEmpty {
                    Section("In corso") {
                        ForEach(inProgress) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                SessionRow(session: session)
                            }
                        }
                        .onDelete { offsets in deleteSessions(inProgress, at: offsets) }
                    }
                }
                Section("Completate") {
                    ForEach(completed) { session in
                        NavigationLink(destination: SessionDetailView(session: session)) {
                            SessionRow(session: session)
                        }
                    }
                    .onDelete { offsets in deleteSessions(completed, at: offsets) }
                }
            }
            .navigationTitle("Sessioni")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { addSession() } label: { Image(systemName: "plus") }
                }
            }
            .overlay {
                if sessions.isEmpty {
                    ContentUnavailableView("Nessuna sessione",
                        systemImage: "drop",
                        description: Text("Tocca + per iniziare una nuova sessione di fusione."))
                }
            }
        }
    }

    private func addSession() {
        let s = CastingSession(title: "Nuova sessione", date: .now)
        context.insert(s)
    }

    private func deleteSessions(_ list: [CastingSession], at offsets: IndexSet) {
        for i in offsets { context.delete(list[i]) }
    }
}

// MARK: - Row

private struct SessionRow: View {
    let session: CastingSession

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(session.title)
                    .font(.headline)
                Text(session.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                StepDots(current: session.currentStep, isComplete: session.isComplete)
                if session.isComplete, let cost = session.totalCost {
                    Text(Format.euros(cost))
                        .font(.subheadline.monospacedDigit())
                } else {
                    Text("step \(session.currentStep)/4")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Step dots

struct StepDots: View {
    let current: Int
    let isComplete: Bool

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...4, id: \.self) { step in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundStyle(step <= current ? Color.primary : Color.secondary.opacity(0.3))
            }
        }
    }
}

// Stub — replaced in Task 6
struct SessionDetailView: View {
    @Bindable var session: CastingSession
    var body: some View { Text(session.title) }
}
