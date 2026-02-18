import Foundation

public struct TimingAppDataLine: Codable, Sendable {
    public var racingNumber: String?
    public var line: Int?
    public var gridPos: String?
    public var stints: TimingAppDataLineStint?

    enum CodingKeys: String, CodingKey {
        case racingNumber = "RacingNumber"
        case line = "Line"
        case gridPos = "GridPos"
        case stints = "Stints"
    }
}

public enum TimingAppDataLineStint: Codable, Sendable {
    case array([LineStint])
    case dictionary([String: LineStint])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let arr = try? container.decode([LineStint].self) {
            self = .array(arr)
            return
        }

        if let dict = try? container.decode([String: LineStint].self) {
            self = .dictionary(dict)
            return
        }

        if let single = try? container.decode(LineStint.self),
           single.lapFlags != nil ||
           single.compound != nil ||
           single.new != nil ||
           single.tyresNotChanged != nil ||
           single.totalLaps != nil ||
           single.startLaps != nil ||
           single.lapTime != nil ||
           single.lapNumber != nil {
            self = .array([single])
            return
        }

        if container.decodeNil() {
            self = .array([])
            return
        }

        throw DecodingError.typeMismatch(
            TimingAppDataLineStint.self,
            DecodingError.Context(codingPath: decoder.codingPath,
                                 debugDescription: "Expected array or dictionary for ArrayOrDict")
        )
    }
}
