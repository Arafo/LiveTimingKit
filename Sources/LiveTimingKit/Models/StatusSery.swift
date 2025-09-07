import Foundation

public struct StatusSeries: Codable, Sendable {
    public let utc: String
    public let trackStatus, sessionStatus: String?

    enum CodingKeys: String, CodingKey {
        case utc = "Utc"
        case trackStatus = "TrackStatus"
        case sessionStatus = "SessionStatus"
    }
}
