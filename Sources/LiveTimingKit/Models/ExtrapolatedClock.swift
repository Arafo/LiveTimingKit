import Foundation

public struct ExtrapolatedClock: Codable, Sendable {
    public let utc: Date = Date.now
    public let remaining: String?
    public let extrapolating: Bool?

    enum CodingKeys: String, CodingKey {
        case remaining = "Remaining"
        case extrapolating = "Extrapolating"
    }
}

extension ExtrapolatedClock {
    public static var empty: Self {
        .init(remaining: nil, extrapolating: nil)
    }
}
