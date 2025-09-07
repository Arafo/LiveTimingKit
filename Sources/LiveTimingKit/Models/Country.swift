import Foundation

public struct Country: Codable, Sendable {
    public let key: Int
    public let code, name: String

    enum CodingKeys: String, CodingKey {
        case key = "Key"
        case code = "Code"
        case name = "Name"
    }
}
