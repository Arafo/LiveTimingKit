import Foundation

struct TimingStatsLine: Codable, Sendable {
    let line: Int
    let racingNumber: String
    let personalBestLapTime: PersonalBestLapTime
    let bestSectors: [BestSector]
    let bestSpeeds: BestSpeeds

    enum CodingKeys: String, CodingKey {
        case line = "Line"
        case racingNumber = "RacingNumber"
        case personalBestLapTime = "PersonalBestLapTime"
        case bestSectors = "BestSectors"
        case bestSpeeds = "BestSpeeds"
    }
}
