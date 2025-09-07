import Foundation

public struct ExtrapolatedClock: Codable, Sendable {
    public let utc, remaining: String
    public let extrapolating: Bool

    enum CodingKeys: String, CodingKey {
        case utc = "Utc"
        case remaining = "Remaining"
        case extrapolating = "Extrapolating"
    }
}

extension ExtrapolatedClock {
    public static var empty: Self {
        .init(utc: "", remaining: "", extrapolating: false)
    }
}
