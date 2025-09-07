import Foundation

public struct LastLapTime: Codable, Sendable {
    public let value: String?
    public let status: Int?
    public let overallFastest: Bool?
    public let personalFastest: Bool?

    enum CodingKeys: String, CodingKey {
        case value = "Value"
        case status = "Status"
        case overallFastest = "OverallFastest"
        case personalFastest = "PersonalFastest"
    }
}
