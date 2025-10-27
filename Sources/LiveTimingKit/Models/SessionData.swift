import Foundation

public struct SessionData: Codable, Sendable {
    public var series: [Series]
    public var statusSeries: [StatusSeries]

    enum CodingKeys: String, CodingKey {
        case series = "Series"
        case statusSeries = "StatusSeries"
    }

    public init(series: [Series] = [], statusSeries: [StatusSeries] = []) {
        self.series = series
        self.statusSeries = statusSeries
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let array = try? container.decode([Series].self, forKey: .series) {
            series = array
        } else if let dict = try? container.decode([String: Series].self, forKey: .series) {
            series = dict
                .sorted { (lhs, rhs) in (Int(lhs.key) ?? 0) < (Int(rhs.key) ?? 0) }
                .map { $0.value }
        } else {
            series = []
        }

        if let array = try? container.decode([StatusSeries].self, forKey: .statusSeries) {
            statusSeries = array
        } else if let dict = try? container.decode([String: StatusSeries].self, forKey: .statusSeries) {
            statusSeries = dict
                .sorted { (lhs, rhs) in (Int(lhs.key) ?? 0) < (Int(rhs.key) ?? 0) }
                .map { $0.value }
        } else {
            statusSeries = []
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(series, forKey: .series)
        try container.encode(statusSeries, forKey: .statusSeries)
    }
}
