import Foundation

public struct RaceControlMessages: Codable, Sendable {
    public let messages: [Message]
    public let kf: Bool?

    enum CodingKeys: String, CodingKey {
        case messages = "Messages"
        case kf = "_kf"
    }
}
