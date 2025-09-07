import Foundation

public struct ArchiveStatus: Codable, Sendable {
    public var status: String?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
    }
}
