import Foundation

public struct Circuit: Codable, Sendable {
    public var key: Int?
    public var shortName: String?

    enum CodingKeys: String, CodingKey {
        case key = "Key"
        case shortName = "ShortName"
    }
}
