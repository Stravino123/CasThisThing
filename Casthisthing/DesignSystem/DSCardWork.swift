import SwiftUI

/// CardWork — card per le lavorazioni nella tab "Pezzi"
/// Figma node 12:102 — 2 stati: Filled (lavorazione esistente) e Default (aggiungi)
struct DSCardWork: View {

    enum Content {
        /// Lavorazione esistente
        case item(name: String, price: String?, photoData: Data?)
        /// Bottone aggiungi
        case addNew
    }

    let content: Content
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            switch content {
            case let .item(name, price, photoData):
                filledContent(name: name, price: price, photoData: photoData)
            case .addNew:
                addNewContent
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Filled

    private func filledContent(name: String, price: String?, photoData: Data?) -> some View {
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

                // Price badge
                if let price {
                    Text(price)
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

            Text(name)
                .font(DS.Font.excon(size: 14, weight: 500))
                .foregroundStyle(DS.Color.textSub)
                .lineLimit(1)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.xl)
                .fill(DS.Color.general)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.xl)
                        .stroke(DS.Color.borderDefault, lineWidth: 1)
                )
        )
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
        DSCardWork(content: .item(name: "Lavorazione 1", price: "2 €", photoData: nil))
        DSCardWork(content: .item(name: "Lavorazione 2", price: "12 €", photoData: nil))
        DSCardWork(content: .addNew)
    }
    .padding()
    .background(DS.Color.canvas)
    .registerFonts()
}
