import Foundation

public struct PitStopSeries: Codable, Sendable {
    public var pitTimes: [String: [String: PitTime]]

    public init(pitTimes: [String: [String: PitTime]] = [:]) {
        self.pitTimes = pitTimes
    }

    enum CodingKeys: String, CodingKey {
        case pitTimes = "PitTimes"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let dict = try? container.decode([String: [String: PitTime]].self, forKey: .pitTimes) {
            pitTimes = dict
        } else if let dict = try? container.decode([String: [PitTime]].self, forKey: .pitTimes) {
            pitTimes = dict.reduce(into: [:]) { result, pair in
                let value = Dictionary(
                    uniqueKeysWithValues: pair.value.enumerated().map { (String($0.offset), $0.element) }
                )
                result[pair.key] = value
            }
        } else {
            pitTimes = [:]
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pitTimes, forKey: .pitTimes)
    }
}

public extension PitStopSeries {
    struct PitTime: Codable, Sendable {
        public var timestamp: String?
        public var pitStop: PitStopEntry?

        public init(timestamp: String? = nil, pitStop: PitStopEntry? = nil) {
            self.timestamp = timestamp
            self.pitStop = pitStop
        }

        enum CodingKeys: String, CodingKey {
            case timestamp = "Timestamp"
            case pitStop = "PitStop"
        }

        public struct PitStopEntry: Codable, Sendable {
            public var racingNumber: String?
            public var pitStopTime: String?
            public var pitLaneTime: String?
            public var lap: String?

            public init(
                racingNumber: String? = nil,
                pitStopTime: String? = nil,
                pitLaneTime: String? = nil,
                lap: String? = nil
            ) {
                self.racingNumber = racingNumber
                self.pitStopTime = pitStopTime
                self.pitLaneTime = pitLaneTime
                self.lap = lap
            }

            enum CodingKeys: String, CodingKey {
                case racingNumber = "RacingNumber"
                case pitStopTime = "PitStopTime"
                case pitLaneTime = "PitLaneTime"
                case lap = "Lap"
            }
        }
    }
}

public extension PitStopSeries {
    mutating func merge(with delta: PitStopSeries) {
        for (driver, stops) in delta.pitTimes {
            if pitTimes[driver] == nil {
                pitTimes[driver] = stops
                continue
            }

            for (index, stop) in stops {
                pitTimes[driver]?[index] = stop
            }
        }
    }
}
