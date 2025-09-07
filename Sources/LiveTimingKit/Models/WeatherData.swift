
public struct WeatherData: Codable, Sendable {
    public var airTemp: String?
    public var trackTemp: String?
    public var humidity: String?
    public var pressure: String?
    public var windSpeed: String?
    public var windDirection: String?

    enum CodingKeys: String, CodingKey {
        case airTemp = "AirTemp", trackTemp = "TrackTemp", humidity = "Humidity",
             pressure = "Pressure", windSpeed = "WindSpeed", windDirection = "WindDirection"
    }
}

extension WeatherData {
    public static var empty: Self {
        .init(airTemp: nil, trackTemp: nil, humidity: nil, pressure: nil, windSpeed: nil, windDirection: nil)
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
    }
}
