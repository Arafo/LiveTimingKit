import Foundation

public struct BestLapTime: Codable, Sendable {
    public let value: String
    public let lap: Int?

    enum CodingKeys: String, CodingKey {
        case value = "Value"
        case lap = "Lap"
    }
}
