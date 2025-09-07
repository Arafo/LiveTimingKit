import Foundation

public struct LineStint: Codable, Sendable {
    public let lapFlags: Int
    public let compound: Compound
    public let new, tyresNotChanged: String
    public let totalLaps, startLaps: Int
    public let lapTime: String?
    public let lapNumber: Int?

    enum CodingKeys: String, CodingKey {
        case lapFlags = "LapFlags"
        case compound = "Compound"
        case new = "New"
        case tyresNotChanged = "TyresNotChanged"
        case totalLaps = "TotalLaps"
        case startLaps = "StartLaps"
        case lapTime = "LapTime"
        case lapNumber = "LapNumber"
    }
}
