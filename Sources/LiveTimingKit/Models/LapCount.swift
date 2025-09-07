import Foundation

public struct LapCount: Codable, Sendable {
    public let currentLap, totalLaps: Int
    public let kf: Bool

    enum CodingKeys: String, CodingKey {
        case currentLap = "CurrentLap"
        case totalLaps = "TotalLaps"
        case kf = "_kf"
    }
}
