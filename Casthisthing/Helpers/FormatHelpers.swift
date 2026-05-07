import Foundation

enum Format {
    /// Formatter generico decimale (fino a 4 cifre) — usato da DSCardDataEntry e ovunque serva.
    static let decimal: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 4
        f.locale = .current
        return f
    }()

    static let grams: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        f.locale = Locale.current
        return f
    }()

    static let currency: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "EUR"
        f.locale = Locale(identifier: "it_IT")
        return f
    }()

    static func grams(_ value: Double?) -> String {
        guard let v = value, let s = grams.string(from: NSNumber(value: v)) else { return "— g" }
        return "\(s) g"
    }

    static func euros(_ value: Double?) -> String {
        guard let v = value, let s = currency.string(from: NSNumber(value: v)) else { return "— €" }
        return s
    }
}
