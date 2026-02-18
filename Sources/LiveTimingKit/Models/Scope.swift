import Foundation

public enum Scope: String, Codable, Sendable {
    case driver = "Driver"
    case sector = "Sector"
    case track = "Track"
    case unknown = "Unknown"

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .unknown
    }
}
