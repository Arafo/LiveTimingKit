import Foundation

public enum Flag: String, Codable, Sendable {
    case blue = "BLUE"
    case chequered = "CHEQUERED"
    case clear = "CLEAR"
    case doubleYellow = "DOUBLE YELLOW"
    case green = "GREEN"
    case yellow = "YELLOW"
    case red = "RED"
    case blackAndWhite = "BLACK AND WHITE"
    case unknown = "UNKNOWN"

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .unknown
    }
}
