
public enum LiveTimingMessage {
    case fullSnapshot(Envelope)
    case heartbeat(Heartbeat)
    case sessionInfo(SessionInfo)
    case timingData(TimingData)
    case timingAppData(TimingAppData)
    case timingStats(TimingStats)
    case driverList(DriverList)
    case carData(CarData)
    case carDataZ(CarData)
    case position(PositionData)
    case positionZ(PositionZ)
    case weather(WeatherData)
    case lapCount(LapCount)
    case raw(String)
}
