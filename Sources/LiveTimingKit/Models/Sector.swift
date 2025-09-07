import Foundation

public struct Sector: Codable, Sendable {
    public let stopped: Bool
    public let value: String
    public let status: Int
    public let overallFastest, personalFastest: Bool
    public let segments: [Segment]
    public let previousValue: String?

    enum CodingKeys: String, CodingKey {
        case stopped = "Stopped"
        case value = "Value"
        case status = "Status"
        case overallFastest = "OverallFastest"
        case personalFastest = "PersonalFastest"
        case segments = "Segments"
        case previousValue = "PreviousValue"
    }
}
