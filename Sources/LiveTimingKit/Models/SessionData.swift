import Foundation

public struct SessionData: Codable, Sendable {
    public let series: [Series]
    public let statusSeries: [StatusSeries]
    public let kf: Bool

    enum CodingKeys: String, CodingKey {
        case series = "Series"
        case statusSeries = "StatusSeries"
        case kf = "_kf"
    }
}
