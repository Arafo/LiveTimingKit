import Foundation

public struct IntervalToPositionAhead: Codable, Sendable {
    public let value: String?
    public let catching: Bool?

    enum CodingKeys: String, CodingKey {
        case value = "Value"
        case catching = "Catching"
    }
}
