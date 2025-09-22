import Foundation

public extension DecoderRegistry {
    static func liveTimingDefault() -> DecoderRegistry {
        let registry = DecoderRegistry()
        registry.register(Heartbeat.self, for: .heartbeat)
        registry.register(CarData.self, for: .carData)
        registry.register(PositionData.self, for: .position)
        registry.register(ExtrapolatedClock.self, for: .extrapolatedClock)
        registry.register(TopThree.self, for: .topThree)
        registry.register(TimingStats.self, for: .timingStats)
        registry.register(TimingAppData.self, for: .timingAppData)
        registry.register(WeatherData.self, for: .weatherData)
        registry.register(TrackStatus.self, for: .trackStatus)
        registry.register(DriverList.self, for: .driverList)
        registry.register(RaceControlMessages.self, for: .raceControlMessages)
        registry.register(SessionInfo.self, for: .sessionInfo)
        registry.register(SessionData.self, for: .sessionData)
        registry.register(LapCount.self, for: .lapCount)
        registry.register(TimingData.self, for: .timingData)
        registry.register(TeamRadio.self, for: .teamRadio)
        registry.register(TyreStintSeries.self, for: .tyreStintSeries)
        return registry
    }
}
