import Foundation

public struct TimingAppDataLine: Codable, Sendable {
    public var racingNumber: String?
    public var line: Int?
    public var gridPos: String?
    public var stints: [String: LineStint]?

    enum CodingKeys: String, CodingKey {
        case racingNumber = "RacingNumber"
        case line = "Line"
        case gridPos = "GridPos"
        case stints = "Stints"
    }

    public init(
        racingNumber: String? = nil,
        line: Int? = nil,
        gridPos: String? = nil,
        stints: [String: LineStint]? = nil
    ) {
        self.racingNumber = racingNumber
        self.line = line
        self.gridPos = gridPos
        self.stints = stints
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        racingNumber = try container.decodeIfPresent(String.self, forKey: .racingNumber)
        line = try container.decodeIfPresent(Int.self, forKey: .line)
        gridPos = try container.decodeIfPresent(String.self, forKey: .gridPos)

        if let dict = try? container.decode([String: LineStint].self, forKey: .stints) {
            stints = dict
        } else if let array = try? container.decode([LineStint].self, forKey: .stints) {
            stints = Dictionary(
                uniqueKeysWithValues: array.enumerated().map { (String($0.offset), $0.element) }
            )
        } else {
            stints = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(racingNumber, forKey: .racingNumber)
        try container.encodeIfPresent(line, forKey: .line)
        try container.encodeIfPresent(gridPos, forKey: .gridPos)
        try container.encodeIfPresent(stints, forKey: .stints)
    }
}
