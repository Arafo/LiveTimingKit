import Foundation

public struct TimingAppDataLine: Codable, Sendable {
    public let racingNumber: String
    public let line: Int
    public let gridPos: String?
    public let stints: [LineStint]

    enum CodingKeys: String, CodingKey {
        case racingNumber = "RacingNumber"
        case line = "Line"
        case gridPos = "GridPos"
        case stints = "Stints"
    }
}
