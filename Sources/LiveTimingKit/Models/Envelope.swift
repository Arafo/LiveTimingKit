import Foundation

public struct Envelope: Codable, Sendable {
    public let heartbeat: Heartbeat?
    public let extrapolatedClock: ExtrapolatedClock?
    public let topThree: TopThree?
    public let timingStats: TimingStats?
    public let timingAppData: TimingAppData?
    public let weatherData: WeatherData?
    public let trackStatus: TrackStatus?
    public let driverList: DriverList?
    public let raceControlMessages: RaceControlMessages?
    public let sessionInfo: SessionInfo?
    public let sessionData: SessionData?
    public let lapCount: LapCount?
    public let timingData: TimingData?
    public let teamRadio: TeamRadio?
    public let tyreStintSeries: TyreStintSeries?

    enum CodingKeys: String, CodingKey {
        case heartbeat = "Heartbeat"
        case extrapolatedClock = "ExtrapolatedClock"
        case topThree = "TopThree"
        case timingStats = "TimingStats"
        case timingAppData = "TimingAppData"
        case weatherData = "WeatherData"
        case trackStatus = "TrackStatus"
        case driverList = "DriverList"
        case raceControlMessages = "RaceControlMessages"
        case sessionInfo = "SessionInfo"
        case sessionData = "SessionData"
        case lapCount = "LapCount"
        case timingData = "TimingData"
        case teamRadio = "TeamRadio"
        case tyreStintSeries = "TyreStintSeries"
    }
}
