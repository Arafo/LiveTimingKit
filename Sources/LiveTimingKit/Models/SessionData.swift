import Foundation

public struct SessionData: Codable, Sendable {
    public let series: [Series]
    public let statusSeries: [StatusSeries]

    enum CodingKeys: String, CodingKey {
        case series = "Series"
        case statusSeries = "StatusSeries"
    }
}
