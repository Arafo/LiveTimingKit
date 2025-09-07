import Foundation

public struct Circuit: Codable, Sendable {
    public let key: Int
    public let shortName: String

    enum CodingKeys: String, CodingKey {
        case key = "Key"
        case shortName = "ShortName"
    }
}
