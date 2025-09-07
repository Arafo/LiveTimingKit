
public enum LiveTimingMessage {
    case fullSnapshot(Envelope)
    case heartbeat(Heartbeat)
    case timingData(TimingData)
    case carData(CarData)
    case position(PositionData)
    case weather(WeatherData)
    case raw(String)
}
