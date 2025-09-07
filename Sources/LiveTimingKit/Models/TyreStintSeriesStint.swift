import Foundation

public struct TyreStintSeriesStint: Codable, Sendable {
    public let compound: Compound
    public let new, tyresNotChanged: String
    public let totalLaps, startLaps: Int

    enum CodingKeys: String, CodingKey {
        case compound = "Compound"
        case new = "New"
        case tyresNotChanged = "TyresNotChanged"
        case totalLaps = "TotalLaps"
        case startLaps = "StartLaps"
    }
}
