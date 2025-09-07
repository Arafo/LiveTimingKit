import Foundation

public struct Capture: Codable, Sendable {
    public let utc, racingNumber, path: String

    enum CodingKeys: String, CodingKey {
        case utc = "Utc"
        case racingNumber = "RacingNumber"
        case path = "Path"
    }
}
