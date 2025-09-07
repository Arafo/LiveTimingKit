import Foundation

public struct LiveTimingState: Codable, Sendable {
    public var heartbeat: Heartbeat = .empty
    public var extrapolatedClock: ExtrapolatedClock?
    public var topThree: TopThree?
    public var timingStats: TimingStats = .empty
    public var timingAppData: TimingAppData?
    public var weatherData: WeatherData = .empty
    public var trackStatus: TrackStatus?
    public var driverList: DriverList?
    public var raceControlMessages: RaceControlMessages?
    public var sessionInfo: SessionInfo?
    public var sessionData: SessionData?
    public var lapCount: LapCount?
    public var timingData: TimingData = .empty
    public var teamRadio: TeamRadio?
    public var tyreStintSeries: TyreStintSeries?
    public var carData: CarData = .empty
    public var positions: PositionData = .empty
}

// MARK: - Empty Extensions for new types
extension ExtrapolatedClock {
    public static var empty: Self {
        .init(utc: "", remaining: "", extrapolating: false, kf: false)
    }
}

extension TopThree {
    public static var empty: Self {
        .init(withheld: false, lines: [], kf: false)
    }
}

extension TimingAppData {
    public static var empty: Self {
        .init(lines: [:], kf: false)
    }
}

extension TrackStatus {
    public static var empty: Self {
        .init(status: "", message: "", kf: false)
    }
}

//extension DriverList {
//    public static var empty: Self {
//        .init(drivers: [:], kf: false)
//    }
//}

extension RaceControlMessages {
    public static var empty: Self {
        .init(messages: [], kf: false)
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
        .init(series: [], statusSeries: [], kf: false)
    }
}

extension LapCount {
    public static var empty: Self {
        .init(currentLap: 0, totalLaps: 0, kf: false)
    }
}

extension TeamRadio {
    public static var empty: Self {
        .init(captures: [], kf: false)
    }
}

extension TyreStintSeries {
    public static var empty: Self {
        .init(stints: [:], kf: false)
    }
}
