import Foundation

public struct TrackStatus: Codable, Sendable {
    public var status: String?
    public var message: String?
    public var kf: Bool?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case kf = "_kf"
    }
}
