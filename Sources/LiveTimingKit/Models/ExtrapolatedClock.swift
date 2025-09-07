import Foundation

public struct ExtrapolatedClock: Codable, Sendable {
    public let utc, remaining: String
    public let extrapolating, kf: Bool

    enum CodingKeys: String, CodingKey {
        case utc = "Utc"
        case remaining = "Remaining"
        case extrapolating = "Extrapolating"
        case kf = "_kf"
    }
}
