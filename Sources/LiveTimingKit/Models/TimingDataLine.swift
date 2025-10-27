import Foundation

public struct TimingDataLine: Codable, Sendable {
    public var gapToLeader: String?
    public var intervalToPositionAhead: Interval?
    public var line: Int?
    public var position: String?
    public var showPosition: Bool?
    public var racingNumber: String?
    public var retired: Bool?
    public var inPit: Bool?
    public var pitOut: Bool?
    public var stopped: Bool?
    public var numberOfPitStops: Int?
    public var numberOfLaps: Int?
    public var knockedOut: Bool?
    public var isPitLap: Bool?
    public var status: StatusFlags?
    public var bestLapTime: BestLap?
    public var lastLapTime: LapSectorTime?
    public var sectors: [String: LapSectorTime]
    public var speeds: [String: LapSectorTime]?

    public init(
        gapToLeader: String? = nil,
        intervalToPositionAhead: Interval? = nil,
        line: Int? = nil,
        position: String? = nil,
        showPosition: Bool? = nil,
        racingNumber: String? = nil,
        retired: Bool? = nil,
        inPit: Bool? = nil,
        pitOut: Bool? = nil,
        stopped: Bool? = nil,
        numberOfPitStops: Int? = nil,
        numberOfLaps: Int? = nil,
        knockedOut: Bool? = nil,
        isPitLap: Bool? = nil,
        status: StatusFlags? = nil,
        bestLapTime: BestLap? = nil,
        lastLapTime: LapSectorTime? = nil,
        sectors: [String: LapSectorTime] = [:],
        speeds: [String: LapSectorTime]? = nil
    ) {
        self.gapToLeader = gapToLeader
        self.intervalToPositionAhead = intervalToPositionAhead
        self.line = line
        self.position = position
        self.showPosition = showPosition
        self.racingNumber = racingNumber
        self.retired = retired
        self.inPit = inPit
        self.pitOut = pitOut
        self.stopped = stopped
        self.numberOfPitStops = numberOfPitStops
        self.numberOfLaps = numberOfLaps
        self.knockedOut = knockedOut
        self.isPitLap = isPitLap
        self.status = status
        self.bestLapTime = bestLapTime
        self.lastLapTime = lastLapTime
        self.sectors = sectors
        self.speeds = speeds
    }

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
        case numberOfPitStops = "NumberOfPitStops"
        case numberOfLaps = "NumberOfLaps"
        case knockedOut = "KnockedOut"
        case isPitLap = "IsPitLap"
        case status = "Status"
        case bestLapTime = "BestLapTime"
        case lastLapTime = "LastLapTime"
        case sectors = "Sectors"
        case speeds = "Speeds"
    }

    private enum AlternateKeys: String, CodingKey {
        case timeDiffToFastest = "TimeDiffToFastest"
        case timeDiffToPositionAhead = "TimeDiffToPositionAhead"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let alternate = try decoder.container(keyedBy: AlternateKeys.self)

        gapToLeader = try container.decodeIfPresent(String.self, forKey: .gapToLeader)
        if gapToLeader == nil {
            gapToLeader = try alternate.decodeIfPresent(String.self, forKey: .timeDiffToFastest)
        }

        intervalToPositionAhead = try container.decodeIfPresent(Interval.self, forKey: .intervalToPositionAhead)
        if intervalToPositionAhead == nil,
           let alt = try alternate.decodeIfPresent(String.self, forKey: .timeDiffToPositionAhead) {
            intervalToPositionAhead = .init(value: alt, catching: nil)
        }

        line = try container.decodeIfPresent(Int.self, forKey: .line)
        position = try container.decodeIfPresent(String.self, forKey: .position)
        showPosition = try container.decodeIfPresent(Bool.self, forKey: .showPosition)
        racingNumber = try container.decodeIfPresent(String.self, forKey: .racingNumber)
        retired = try container.decodeIfPresent(Bool.self, forKey: .retired)
        inPit = try container.decodeIfPresent(Bool.self, forKey: .inPit)
        pitOut = try container.decodeIfPresent(Bool.self, forKey: .pitOut)
        stopped = try container.decodeIfPresent(Bool.self, forKey: .stopped)
        numberOfPitStops = try container.decodeIfPresent(Int.self, forKey: .numberOfPitStops)
        numberOfLaps = try container.decodeIfPresent(Int.self, forKey: .numberOfLaps)
        knockedOut = try container.decodeIfPresent(Bool.self, forKey: .knockedOut)
        isPitLap = try container.decodeIfPresent(Bool.self, forKey: .isPitLap)
        status = try container.decodeIfPresent(StatusFlags.self, forKey: .status)

        bestLapTime = try container.decodeIfPresent(BestLap.self, forKey: .bestLapTime)
        lastLapTime = try container.decodeIfPresent(LapSectorTime.self, forKey: .lastLapTime)

        if let dict = try? container.decode([String: LapSectorTime].self, forKey: .sectors) {
            sectors = dict
        } else if let array = try? container.decode([LapSectorTime].self, forKey: .sectors) {
            sectors = Dictionary(uniqueKeysWithValues: array.enumerated().map { (String($0.offset), $0.element) })
        } else {
            sectors = [:]
        }

        if let dict = try? container.decode([String: LapSectorTime].self, forKey: .speeds) {
            speeds = dict
        } else if let array = try? container.decode([LapSectorTime].self, forKey: .speeds) {
            speeds = Dictionary(uniqueKeysWithValues: array.enumerated().map { (String($0.offset), $0.element) })
        } else {
            speeds = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(gapToLeader, forKey: .gapToLeader)
        try container.encodeIfPresent(intervalToPositionAhead, forKey: .intervalToPositionAhead)
        try container.encodeIfPresent(line, forKey: .line)
        try container.encodeIfPresent(position, forKey: .position)
        try container.encodeIfPresent(showPosition, forKey: .showPosition)
        try container.encodeIfPresent(racingNumber, forKey: .racingNumber)
        try container.encodeIfPresent(retired, forKey: .retired)
        try container.encodeIfPresent(inPit, forKey: .inPit)
        try container.encodeIfPresent(pitOut, forKey: .pitOut)
        try container.encodeIfPresent(stopped, forKey: .stopped)
        try container.encodeIfPresent(numberOfPitStops, forKey: .numberOfPitStops)
        try container.encodeIfPresent(numberOfLaps, forKey: .numberOfLaps)
        try container.encodeIfPresent(knockedOut, forKey: .knockedOut)
        try container.encodeIfPresent(isPitLap, forKey: .isPitLap)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(bestLapTime, forKey: .bestLapTime)
        try container.encodeIfPresent(lastLapTime, forKey: .lastLapTime)

        if !sectors.isEmpty {
            try container.encode(sectors, forKey: .sectors)
        }

        if let speeds {
            try container.encode(speeds, forKey: .speeds)
        }
    }
}

extension TimingDataLine {
    public mutating func merge(with delta: TimingDataLine) {
        if let value = delta.gapToLeader { gapToLeader = value }
        if let value = delta.intervalToPositionAhead {
            if var existing = intervalToPositionAhead {
                existing.merge(with: value)
                intervalToPositionAhead = existing
            } else {
                intervalToPositionAhead = value
            }
        }
        if let value = delta.line { line = value }
        if let value = delta.position { position = value }
        if let value = delta.showPosition { showPosition = value }
        if let value = delta.racingNumber { racingNumber = value }
        if let value = delta.retired { retired = value }
        if let value = delta.inPit { inPit = value }
        if let value = delta.pitOut { pitOut = value }
        if let value = delta.stopped { stopped = value }
        if let value = delta.numberOfPitStops { numberOfPitStops = value }
        if let value = delta.numberOfLaps { numberOfLaps = value }
        if let value = delta.knockedOut { knockedOut = value }
        if let value = delta.isPitLap { isPitLap = value }
        if let value = delta.status { status = value }

        if let value = delta.bestLapTime {
            if var existing = bestLapTime {
                existing.merge(with: value)
                bestLapTime = existing
            } else {
                bestLapTime = value
            }
        }

        if let value = delta.lastLapTime {
            if var existing = lastLapTime {
                existing.merge(with: value)
                lastLapTime = existing
            } else {
                lastLapTime = value
            }
        }

        if !delta.sectors.isEmpty {
            for (key, sector) in delta.sectors {
                if var existing = sectors[key] {
                    existing.merge(with: sector)
                    sectors[key] = existing
                } else {
                    sectors[key] = sector
                }
            }
        }

        if let speedsUpdate = delta.speeds {
            if speeds == nil { speeds = [:] }
            for (key, speed) in speedsUpdate {
                if var existing = speeds?[key] {
                    existing.merge(with: speed)
                    speeds?[key] = existing
                } else {
                    speeds?[key] = speed
                }
            }
        }
    }
}

public extension TimingDataLine {
    struct Interval: Codable, Sendable {
        public var value: String?
        public var catching: Bool?

        public init(value: String? = nil, catching: Bool? = nil) {
            self.value = value
            self.catching = catching
        }

        enum CodingKeys: String, CodingKey {
            case value = "Value"
            case catching = "Catching"
        }

        public mutating func merge(with delta: Interval) {
            if let value = delta.value { self.value = value }
            if let catching = delta.catching { self.catching = catching }
        }
    }

    struct BestLap: Codable, Sendable {
        public var value: String?
        public var lap: Int?

        public init(value: String? = nil, lap: Int? = nil) {
            self.value = value
            self.lap = lap
        }

        enum CodingKeys: String, CodingKey {
            case value = "Value"
            case lap = "Lap"
        }

        public mutating func merge(with delta: BestLap) {
            if let value = delta.value { self.value = value }
            if let lap = delta.lap { self.lap = lap }
        }
    }

    struct LapSectorTime: Codable, Sendable {
        public var value: String?
        public var status: StatusFlags?
        public var overallFastest: Bool?
        public var personalFastest: Bool?
        public var segments: [Int: Segment]
        public var stopped: Bool?
        public var previousValue: String?

        public init(
            value: String? = nil,
            status: StatusFlags? = nil,
            overallFastest: Bool? = nil,
            personalFastest: Bool? = nil,
            segments: [Int: Segment] = [:],
            stopped: Bool? = nil,
            previousValue: String? = nil
        ) {
            self.value = value
            self.status = status
            self.overallFastest = overallFastest
            self.personalFastest = personalFastest
            self.segments = segments
            self.stopped = stopped
            self.previousValue = previousValue
        }

        enum CodingKeys: String, CodingKey {
            case value = "Value"
            case status = "Status"
            case overallFastest = "OverallFastest"
            case personalFastest = "PersonalFastest"
            case segments = "Segments"
            case stopped = "Stopped"
            case previousValue = "PreviousValue"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            value = try container.decodeIfPresent(String.self, forKey: .value)
            status = try container.decodeIfPresent(StatusFlags.self, forKey: .status)
            overallFastest = try container.decodeIfPresent(Bool.self, forKey: .overallFastest)
            personalFastest = try container.decodeIfPresent(Bool.self, forKey: .personalFastest)
            stopped = try container.decodeIfPresent(Bool.self, forKey: .stopped)
            previousValue = try container.decodeIfPresent(String.self, forKey: .previousValue)

            if let dict = try? container.decode([Int: Segment].self, forKey: .segments) {
                segments = dict
            } else if let dict = try? container.decode([String: Segment].self, forKey: .segments) {
                segments = dict.reduce(into: [:]) { result, pair in
                    if let key = Int(pair.key) { result[key] = pair.value }
                }
            } else if let array = try? container.decode([Segment].self, forKey: .segments) {
                segments = Dictionary(uniqueKeysWithValues: array.enumerated().map { ($0.offset, $0.element) })
            } else {
                segments = [:]
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(value, forKey: .value)
            try container.encodeIfPresent(status, forKey: .status)
            try container.encodeIfPresent(overallFastest, forKey: .overallFastest)
            try container.encodeIfPresent(personalFastest, forKey: .personalFastest)
            try container.encodeIfPresent(stopped, forKey: .stopped)
            try container.encodeIfPresent(previousValue, forKey: .previousValue)
            if !segments.isEmpty {
                let stringKeyed = segments.reduce(into: [String: Segment]()) { result, pair in
                    result[String(pair.key)] = pair.value
                }
                try container.encode(stringKeyed, forKey: .segments)
            }
        }

        public mutating func merge(with delta: LapSectorTime) {
            if let value = delta.value { self.value = value }
            if let status = delta.status { self.status = status }
            if let overallFastest = delta.overallFastest { self.overallFastest = overallFastest }
            if let personalFastest = delta.personalFastest { self.personalFastest = personalFastest }
            if let stopped = delta.stopped { self.stopped = stopped }
            if let previousValue = delta.previousValue { self.previousValue = previousValue }

            if !delta.segments.isEmpty {
                for (key, segment) in delta.segments {
                    if var existing = segments[key] {
                        existing.merge(with: segment)
                        segments[key] = existing
                    } else {
                        segments[key] = segment
                    }
                }
            }
        }

        public struct Segment: Codable, Sendable {
            public var status: StatusFlags?

            public init(status: StatusFlags? = nil) {
                self.status = status
            }

            enum CodingKeys: String, CodingKey {
                case status = "Status"
            }

            public mutating func merge(with delta: Segment) {
                if let status = delta.status { self.status = status }
            }
        }
    }

    struct StatusFlags: OptionSet, Codable, Sendable {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(Int.self)
            self.init(rawValue: value)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }

        public static let personalBest = StatusFlags(rawValue: 1)
        public static let overallBest = StatusFlags(rawValue: 2)
        public static let pitLane = StatusFlags(rawValue: 16)
        public static let chequeredFlag = StatusFlags(rawValue: 1024)
        public static let segmentComplete = StatusFlags(rawValue: 2048)
    }
}
