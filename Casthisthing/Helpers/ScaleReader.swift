import UIKit
import Vision

/// Legge il peso dal display di una bilancia fotografata, on-device con Apple Vision.
enum ScaleReader {

    static func readWeight(from image: UIImage) async -> Double? {
        guard let cgImage = image.cgImage else { return nil }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)

        return await Task.detached(priority: .userInitiated) {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false

            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation)
            guard (try? handler.perform([request])) != nil,
                  let observations = request.results else { return nil }

            return bestCandidate(in: observations)
        }.value
    }

    private struct Candidate {
        let value: Double
        let score: Double
    }

    private static let numberPattern = /(\d{1,4})(?:\s?[.,]\s?(\d{1,3}))?\s*(g|gr)?/

    private static func bestCandidate(in observations: [VNRecognizedTextObservation]) -> Double? {
        var candidates: [Candidate] = []

        for obs in observations {
            // Le cifre del display sono in genere il testo più grande nella foto.
            let height = Double(obs.boundingBox.height)
            for text in obs.topCandidates(3) {
                let cleaned = text.string
                    .replacingOccurrences(of: "O", with: "0")
                    .replacingOccurrences(of: "o", with: "0")
                for match in cleaned.matches(of: numberPattern) {
                    let intPart = String(match.output.1)
                    let fracPart = match.output.2.map(String.init)
                    let raw = fracPart.map { "\(intPart).\($0)" } ?? intPart
                    guard let value = Double(raw), value > 0, value < 5000 else { continue }

                    // La dimensione domina: diciture piccole come "Max 500g" o "d=0.01g" non devono vincere.
                    var score = height * 100 + Double(text.confidence)
                    if fracPart != nil { score += 1 }
                    if match.output.3 != nil { score += 0.5 }
                    candidates.append(Candidate(value: value, score: score))
                }
            }
        }

        return candidates.max(by: { $0.score < $1.score })?.value
    }
}

private extension CGImagePropertyOrientation {
    init(_ o: UIImage.Orientation) {
        switch o {
        case .up:            self = .up
        case .down:          self = .down
        case .left:          self = .left
        case .right:         self = .right
        case .upMirrored:    self = .upMirrored
        case .downMirrored:  self = .downMirrored
        case .leftMirrored:  self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default:    self = .up
        }
    }
}
