import Foundation

public struct Country: Codable, Sendable {
    public var key: Int?
    public var code: String?
    public var name: String?

    enum CodingKeys: String, CodingKey {
        case key = "Key"
        case code = "Code"
        case name = "Name"
    }
}
