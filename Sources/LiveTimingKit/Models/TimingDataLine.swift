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
    public var sectors: [Sector]?
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
