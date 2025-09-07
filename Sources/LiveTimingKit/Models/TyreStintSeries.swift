import Foundation

public struct TyreStintSeries: Codable, Sendable {
    public let stints: [String: [TyreStintSeriesStint]]

    enum CodingKeys: String, CodingKey {
        case stints = "Stints"
    }
}
