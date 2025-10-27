import Foundation

public struct ExtrapolatedClock: Codable, Sendable {
    public var utc: String?
    public var remaining: String?
    public var extrapolating: Bool?

    enum CodingKeys: String, CodingKey {
        case utc = "Utc"
        case remaining = "Remaining"
        case extrapolating = "Extrapolating"
    }
}

extension ExtrapolatedClock {
    public static var empty: Self {
        .init(utc: nil, remaining: nil, extrapolating: nil)
    }
}
