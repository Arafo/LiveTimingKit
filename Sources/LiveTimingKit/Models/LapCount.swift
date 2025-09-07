import Foundation

public struct LapCount: Codable, Sendable {
    public let currentLap, totalLaps: Int

    enum CodingKeys: String, CodingKey {
        case currentLap = "CurrentLap"
        case totalLaps = "TotalLaps"
    }
}
