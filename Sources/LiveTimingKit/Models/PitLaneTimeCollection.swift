import Foundation

public struct PitLaneTimeCollection: Codable, Sendable {
    public var pitTimes: [String: PitTime]
    public var pitTimesList: [String: [PitTime]]

    public init(
        pitTimes: [String: PitTime] = [:],
        pitTimesList: [String: [PitTime]] = [:]
    ) {
        self.pitTimes = pitTimes
        self.pitTimesList = pitTimesList
    }

    enum CodingKeys: String, CodingKey {
        case pitTimes = "PitTimes"
        case pitTimesList = "PitTimesList"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let dict = try? container.decode([String: PitTime].self, forKey: .pitTimes) {
            pitTimes = dict
        } else {
            pitTimes = [:]
        }

        if let dict = try? container.decode([String: [PitTime]].self, forKey: .pitTimesList) {
            pitTimesList = dict
        } else if let dict = try? container.decode([String: [String: PitTime]].self, forKey: .pitTimesList) {
            pitTimesList = dict.mapValues { $0.values.map { $0 } }
        } else {
            pitTimesList = [:]
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pitTimes, forKey: .pitTimes)
        try container.encode(pitTimesList, forKey: .pitTimesList)
    }

    public struct PitTime: Codable, Sendable {
        public var duration: String?
        public var lap: String?

        public init(duration: String? = nil, lap: String? = nil) {
            self.duration = duration
            self.lap = lap
        }

        enum CodingKeys: String, CodingKey {
            case duration = "Duration"
            case lap = "Lap"
        }
    }
}

public extension PitLaneTimeCollection {
    mutating func merge(with delta: PitLaneTimeCollection) {
        for (key, value) in delta.pitTimes {
            pitTimes[key] = value
        }

        for (key, list) in delta.pitTimesList {
            if pitTimesList[key] == nil {
                pitTimesList[key] = list
            } else {
                pitTimesList[key]?.append(contentsOf: list)
            }
        }
    }
}
