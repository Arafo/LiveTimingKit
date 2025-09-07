import Foundation

public struct Segment: Codable, Sendable {
    public let status: Int

    enum CodingKeys: String, CodingKey {
        case status = "Status"
    }
}
