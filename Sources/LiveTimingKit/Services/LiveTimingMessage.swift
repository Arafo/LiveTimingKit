
public enum LiveTimingMessage {
    case fullSnapshot(Envelope)
    case heartbeat(Heartbeat)
    case timingData(TimingData)
    case timingAppData(TimingAppData)
    case carData(CarData)
    case position(PositionData)
    case weather(WeatherData)
    case raw(String)
}
