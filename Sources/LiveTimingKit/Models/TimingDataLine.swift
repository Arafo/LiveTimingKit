import Foundation

public struct TimingDataLine: Codable, Sendable {
    public var gapToLeader: String?
    public var intervalToPositionAhead: IntervalToPositionAhead?
    public var line: Int?
    public var position: String?
    public var showPosition: Bool?
    public var racingNumber: String?
    public var retired: Bool?
    public var inPit: Bool?
    public var pitOut: Bool?
    public var stopped: Bool?
    public var status: Int?
    public var sectors: TimingDataLineSector?
    public var speeds: Speeds?
    public var bestLapTime: BestLapTime?
    public var lastLapTime: LastLapTime?
    public var numberOfLaps: Int?
    public var numberOfPitStops: Int?

    enum CodingKeys: String, CodingKey {
        case gapToLeader = "GapToLeader"
        case intervalToPositionAhead = "IntervalToPositionAhead"
        case line = "Line"
        case position = "Position"
        case showPosition = "ShowPosition"
        case racingNumber = "RacingNumber"
        case retired = "Retired"
        case inPit = "InPit"
        case pitOut = "PitOut"
        case stopped = "Stopped"
        case status = "Status"
        case sectors = "Sectors"
        case speeds = "Speeds"
        case bestLapTime = "BestLapTime"
        case lastLapTime = "LastLapTime"
        case numberOfLaps = "NumberOfLaps"
        case numberOfPitStops = "NumberOfPitStops"
    }
}

public struct TimingDataLineSector: Codable, Sendable {
    public var sectorsByLap: [String: [Sector]]

    public init(sectorsByLap: [String: [Sector]]) {
        self.sectorsByLap = sectorsByLap
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // 1. Try [Sector] — most common case
        if let array = try? container.decode([Sector].self) {
            self.sectorsByLap = ["1": array]
            return
        }

        // 2. Try [String: [Sector]]
        if let dict = try? container.decode([String: [Sector]].self) {
            self.sectorsByLap = dict
            return
        }

        // 3. Try [String: [String: Sector]]
        if let nested = try? container.decode([String: [String: Sector]].self) {
            var result: [String: [Sector]] = [:]
            for (key, inner) in nested {
                result[key] = Array(inner.values)
            }
            self.sectorsByLap = result
            return
        }

        // 4. Try [String: Sector]
        if let singleDict = try? container.decode([String: Sector].self) {
            self.sectorsByLap = singleDict.mapValues { [$0] }
            return
        }

        // 5. Handle null
        if container.decodeNil() {
            self.sectorsByLap = [:]
            return
        }

        // 6. Fail gracefully
        throw DecodingError.typeMismatch(
            TimingDataLineSector.self,
            .init(codingPath: decoder.codingPath,
                  debugDescription: "Unsupported format for TimingDataLineSector")
        )
    }

    public func encode(to encoder: Encoder) throws {
        // Re-encode in canonical format [String: [Sector]]
        var container = encoder.singleValueContainer()
        try container.encode(sectorsByLap)
    }
}


public enum TimingDataLineSector1: Codable, Sendable {
    case array([Sector])
    case dictionary2([String: Sector])
    case dictionary([String: [Sector]])
    case dictionary1([String: [String: Sector]])


    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let arr = try? container.decode([Sector].self) {
            self = .array(arr)
            return
        }

        if let dict = try? container.decode([String: [Sector]].self) {
            self = .dictionary(dict)
            return
        }
        
        if let dict = try? container.decode([String: [String: Sector]].self) {
            self = .dictionary1(dict)
            return
        }
        
        if let dict = try? container.decode([String: Sector].self) {
            self = .dictionary2(dict)
            return
        }

        if container.decodeNil() {
            self = .array([])
            return
        }

        throw DecodingError.typeMismatch(
            TimingDataLineSector.self,
            DecodingError.Context(codingPath: decoder.codingPath,
                                 debugDescription: "Expected array or dictionary for ArrayOrDict")
        )
    }
    
}

//extension TimingDataLineSector {
//    public mutating func merge(with delta: TimingDataLineSector) {
//        switch self {
//        case let .array(sectors):
//            self = .dictionary(["1": sectors])
//        case let .dictionary2(sectors):
//            self = .dictionary(sectors.compactMapValues { [$0] })
//        case let .dictionary(sectors):
//            self = .dictionary(sectors)
//        case let .dictionary1(sectors):
//            var result: [String: [Sector]] = [:]
//            for (outerKey, innerDict) in sectors {
//                result[outerKey] = Array(innerDict.values)
//            }
//            self = .dictionary(result)
//        }
//    }
//}
