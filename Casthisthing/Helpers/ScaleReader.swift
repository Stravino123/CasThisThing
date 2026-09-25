import UIKit

enum ScaleReading: Equatable {
    case weight(Double)
    case notFound
    case missingKey
    case failed(String)
}

/// Legge il peso dal display di una bilancia fotografata tramite Gemini.
/// Apple Vision è stato scartato: non riconosce i display LCD a segmenti.
enum ScaleReader {
    static let model = "gemini-3.8-flash"

    private static let prompt = """
    This photo shows a jewelry piece on a digital scale. Read the weight shown on the \
    scale's display (often a seven-segment LCD, possibly backlit, angled or with glare). \
    Pay close attention to the decimal point: "2.59" and "259" are very different. \
    Return the weight in grams; if the display shows another unit (ct, oz, dwt) convert it to grams. \
    Ignore any printed labels on the scale body such as capacity or precision. \
    If you cannot read the display with confidence, return null.
    """

    static func readWeight(from image: UIImage) async -> ScaleReading {
        guard let key = KeychainStore.geminiKey, !key.isEmpty else { return .missingKey }
        guard let jpeg = image.downscaled(maxSide: 1600).jpegData(compressionQuality: 0.8) else {
            return .notFound
        }

        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent")!
        var request = URLRequest(url: url, timeoutInterval: 30)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(key, forHTTPHeaderField: "x-goog-api-key")

        let body: [String: Any] = [
            "contents": [[
                "parts": [
                    ["inline_data": ["mime_type": "image/jpeg", "data": jpeg.base64EncodedString()]],
                    ["text": prompt],
                ],
            ]],
            "generationConfig": [
                "temperature": 0,
                "response_mime_type": "application/json",
                "response_schema": [
                    "type": "OBJECT",
                    "properties": ["weight_grams": ["type": "NUMBER", "nullable": true]],
                    "required": ["weight_grams"],
                ],
            ],
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard status == 200 else { return .failed(message(for: status, data: data)) }
            return parse(data)
        } catch {
            return .failed("Connessione non riuscita. Controlla di essere online.")
        }
    }

    private struct GeminiResponse: Decodable {
        struct Candidate: Decodable { let content: Content? }
        struct Content: Decodable { let parts: [Part]? }
        struct Part: Decodable { let text: String? }
        let candidates: [Candidate]?
    }

    private struct WeightPayload: Decodable {
        let weight_grams: Double?
    }

    private static func parse(_ data: Data) -> ScaleReading {
        guard let response = try? JSONDecoder().decode(GeminiResponse.self, from: data),
              let text = response.candidates?.first?.content?.parts?.compactMap(\.text).joined(),
              let payload = try? JSONDecoder().decode(WeightPayload.self, from: Data(text.utf8)),
              let grams = payload.weight_grams, grams > 0, grams < 5000
        else { return .notFound }
        return .weight(grams)
    }

    private static func message(for status: Int, data: Data) -> String {
        let body = String(data: data, encoding: .utf8) ?? ""
        switch status {
        case 400 where body.contains("API_KEY_INVALID"):
            return "La chiave Gemini non è valida. Controllala dal menu ⋯ → Chiave AI."
        case 429:
            return "Limite gratuito di Gemini raggiunto. Riprova più tardi."
        case 403:
            return "La chiave non ha accesso a Gemini."
        case 404:
            return "Il modello Gemini non è disponibile."
        default:
            return "Errore di Gemini (\(status))."
        }
    }
}

private extension UIImage {
    func downscaled(maxSide: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        guard longest > maxSide else { return self }
        let scale = maxSide / longest
        let target = CGSize(width: size.width * scale, height: size.height * scale)
        return UIGraphicsImageRenderer(size: target).image { _ in draw(in: CGRect(origin: .zero, size: target)) }
    }
}
