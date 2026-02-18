import Foundation

public enum Category: String, Codable, Sendable {
    case drs = "Drs"
    case flag = "Flag"
    case other = "Other"
    case safetyCar = "SafetyCar"

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .other
    }
}
