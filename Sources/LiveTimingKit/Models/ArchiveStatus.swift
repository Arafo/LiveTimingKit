import Foundation

public struct ArchiveStatus: Codable, Sendable {
    public let status: String

    enum CodingKeys: String, CodingKey {
        case status = "Status"
    }
}
