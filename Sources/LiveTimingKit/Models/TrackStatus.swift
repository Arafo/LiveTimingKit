import Foundation

public struct TrackStatus: Codable, Sendable {
    public let status, message: String
    public let kf: Bool

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case kf = "_kf"
    }
}
