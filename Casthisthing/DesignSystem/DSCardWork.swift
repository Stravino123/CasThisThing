import SwiftUI

/// Contenuto possibile di una DSCardWork.
enum DSCardWorkContent {
    /// Lavorazione esistente: nome, badge opzionale (es. grammi), foto, stato vendita
    case item(name: String, badge: String?, photoData: Data?, isSold: Bool = false)
    /// Bottone aggiungi nuova lavorazione
    case addNew
}

/// CardWork — card per le lavorazioni nella tab "Lavorazioni"
/// Figma node 12:102 — 2 stati: Filled (lavorazione esistente) e Default (aggiungi)
struct DSCardWork: View {

    let content: DSCardWorkContent
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            switch content {
            case let .item(name, badge, photoData, isSold):
                filledContent(name: name, badge: badge, photoData: photoData, isSold: isSold)
            case .addNew:
                addNewContent
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Filled

    private func filledContent(name: String, badge: String?, photoData: Data?, isSold: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                // Avatar / thumbnail
                Group {
                    if let data = photoData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        DS.Color.disabled
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundStyle(DS.Color.textSub)
                                    .font(.system(size: 16))
                            )
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 13))

                Spacer()

                // Badge (es. grammi argento)
                if let badge {
                    Text(badge)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(DS.Color.primary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(DS.Color.primaryLight)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(DS.Color.borderGeneral, lineWidth: 1)
                                )
                        )
                }
            }

            VStack(alignment: .leading, spacing: DS.Space.sm) {
                Text(name)
                    .font(DS.Font.excon(size: 14, weight: 500))
                    .foregroundStyle(DS.Color.textSub)
                    .lineLimit(1)
                DSSoldTag(isSold: isSold)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(border: DS.Color.borderDefault)
    }

    // MARK: - Add New

    private var addNewContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Plus icon in 40×40 container
            DSIcon.plus.view(size: 30, color: DS.Color.primary)
                .frame(width: 40, height: 40)

            Text("Aggiungi")
                .font(DS.Font.excon(size: 14, weight: 500))
                .foregroundStyle(DS.Color.primary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 108, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.xl)
                .fill(DS.Color.general)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.xl)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                        .foregroundStyle(DS.Color.primary)
                )
        )
    }
}

// MARK: - Preview

#Preview("CardWork") {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
        DSCardWork(content: .item(name: "#1", badge: "2.5 g", photoData: nil, isSold: true))
        DSCardWork(content: .item(name: "#2", badge: nil,    photoData: nil))
        DSCardWork(content: .addNew)
    }
    .padding()
    .background(DS.Color.canvas)
    .registerFonts()
}
