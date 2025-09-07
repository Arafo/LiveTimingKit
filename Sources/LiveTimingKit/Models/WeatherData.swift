
public struct WeatherData: Codable, Sendable {
    public var airTemp: String?
    public var trackTemp: String?
    public var humidity: String?
    public var pressure: String?
    public var windSpeed: String?
    public var windDirection: String?
    public var rainfall: String?

    enum CodingKeys: String, CodingKey {
        case airTemp = "AirTemp"
        case trackTemp = "TrackTemp"
        case humidity = "Humidity"
        case pressure = "Pressure"
        case windSpeed = "WindSpeed"
        case windDirection = "WindDirection"
        case rainfall = "Rainfall"
    }
}

extension WeatherData {
    public static var empty: Self {
        .init(
            airTemp: nil,
            trackTemp: nil,
            humidity: nil,
            pressure: nil,
            windSpeed: nil,
            windDirection: nil,
            rainfall: nil
        )
    }
}

extension WeatherData {
    public mutating func merge(with delta: WeatherData) {
        if let v = delta.airTemp { airTemp = v }
        if let v = delta.trackTemp { trackTemp = v }
        if let v = delta.humidity { humidity = v }
        if let v = delta.pressure { pressure = v }
        if let v = delta.windSpeed { windSpeed = v }
        if let v = delta.windDirection { windDirection = v }
        if let v = delta.rainfall { rainfall = v }
    }
}
