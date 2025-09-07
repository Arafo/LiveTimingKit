import Foundation

public struct TyreStintSeries: Codable, Sendable {
    public let stints: [String: [TyreStintSeriesStint]]
    public let kf: Bool

    enum CodingKeys: String, CodingKey {
        case stints = "Stints"
        case kf = "_kf"
    }
}
