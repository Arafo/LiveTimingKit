import Foundation

public struct Series: Codable, Sendable {
    public let utc: String
    public let lap: Int?

    enum CodingKeys: String, CodingKey {
        case utc = "Utc"
        case lap = "Lap"
    }
}
