import Foundation

struct TimingStatsLine: Codable, Sendable {
    let line: Int?
    let racingNumber: String?
    let personalBestLapTime: PersonalBestLapTime?
    let bestSectors: TimingStatsLineBestSector?
    let bestSpeeds: BestSpeeds?

    enum CodingKeys: String, CodingKey {
        case line = "Line"
        case racingNumber = "RacingNumber"
        case personalBestLapTime = "PersonalBestLapTime"
        case bestSectors = "BestSectors"
        case bestSpeeds = "BestSpeeds"
    }
}

enum TimingStatsLineBestSector: Codable, Sendable {
    case array([BestSector])
    case dictionary([String: BestSector])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let arr = try? container.decode([BestSector].self) {
            self = .array(arr)
            return
        }

        if let dict = try? container.decode([String: BestSector].self) {
            self = .dictionary(dict)
            return
        }

        if container.decodeNil() {
            self = .array([])
            return
        }

        throw DecodingError.typeMismatch(
            TimingStatsLineBestSector.self,
            DecodingError.Context(codingPath: decoder.codingPath,
                                 debugDescription: "Expected array or dictionary for ArrayOrDict")
        )
    }
    
}
