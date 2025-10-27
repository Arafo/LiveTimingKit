import Foundation

public struct LiveTimingState: Codable, Sendable {
    public init(
        heartbeat: Heartbeat = .empty,
        extrapolatedClock: ExtrapolatedClock = .empty,
        topThree: TopThree? = nil,
        timingStats: TimingStats = .empty,
        timingAppData: TimingAppData = .empty,
        weatherData: WeatherData = .empty,
        trackStatus: TrackStatus? = nil,
        driverList: DriverList = .empty,
        raceControlMessages: RaceControlMessages? = nil,
        sessionInfo: SessionInfo? = nil,
        sessionData: SessionData? = nil,
        lapCount: LapCount = .empty,
        timingData: TimingData = .empty,
        teamRadio: TeamRadio? = nil,
        tyreStintSeries: TyreStintSeries? = nil,
        championshipPrediction: ChampionshipPrediction? = nil,
        pitStopSeries: PitStopSeries? = nil,
        pitLaneTimeCollection: PitLaneTimeCollection? = nil,
        carData: CarData = .empty,
        positionZ: PositionZ = .empty
    ) {
        self.heartbeat = heartbeat
        self.extrapolatedClock = extrapolatedClock
        self.topThree = topThree
        self.timingStats = timingStats
        self.timingAppData = timingAppData
        self.weatherData = weatherData
        self.trackStatus = trackStatus
        self.driverList = driverList
        self.raceControlMessages = raceControlMessages
        self.sessionInfo = sessionInfo
        self.sessionData = sessionData
        self.lapCount = lapCount
        self.timingData = timingData
        self.teamRadio = teamRadio
        self.tyreStintSeries = tyreStintSeries
        self.championshipPrediction = championshipPrediction
        self.pitStopSeries = pitStopSeries
        self.pitLaneTimeCollection = pitLaneTimeCollection
        self.carData = carData
        self.positionZ = positionZ
    }
    
    public var heartbeat: Heartbeat = .empty
    public var extrapolatedClock: ExtrapolatedClock = .empty
    public var topThree: TopThree?
    public var timingStats: TimingStats = .empty
    public var timingAppData: TimingAppData = .empty
    public var weatherData: WeatherData = .empty
    public var trackStatus: TrackStatus?
    public var driverList: DriverList = .empty
    public var raceControlMessages: RaceControlMessages?
    public var sessionInfo: SessionInfo?
    public var sessionData: SessionData?
    public var lapCount: LapCount = .empty
    public var timingData: TimingData = .empty
    public var teamRadio: TeamRadio?
    public var tyreStintSeries: TyreStintSeries?
    public var championshipPrediction: ChampionshipPrediction?
    public var pitStopSeries: PitStopSeries?
    public var pitLaneTimeCollection: PitLaneTimeCollection?
    public var carData: CarData = .empty
    public var positionZ: PositionZ = .empty
}

// MARK: - Empty Extensions for new types

extension TopThree {
    public static var empty: Self {
        .init(withheld: false, lines: [], kf: false)
    }
}

extension TimingAppData {
    public static var empty: Self {
        .init(lines: [:])
    }
}

extension TrackStatus {
    public static var empty: Self {
        .init(status: nil, message: nil, kf: false)
    }
}

extension RaceControlMessages {
    public static var empty: Self {
        .init(messages: [:], kf: false)
    }
}

//extension SessionInfo {
//    public static var empty: Self {
//        .init(
//            meeting: Meeting.empty,
//            sessionStatus: "",
//            archiveStatus: ArchiveStatus.empty,
//            key: 0,
//            type: "",
//            name: "",
//            startDate: "",
//            endDate: "",
//            gmtOffset: "",
//            path: "",
//            kf: false
//        )
//    }
//}

extension SessionData {
    public static var empty: Self {
        .init(series: [], statusSeries: [])
    }
}

extension TeamRadio {
    public static var empty: Self {
        .init(captures: [:])
    }
}

extension TyreStintSeries {
    public static var empty: Self {
        .init(stints: [:])
    }
}

extension ChampionshipPrediction {
    public static var empty: Self {
        .init()
    }
}

extension PitStopSeries {
    public static var empty: Self {
        .init()
    }
}

extension PitLaneTimeCollection {
    public static var empty: Self {
        .init()
    }
}
