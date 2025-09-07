import Foundation

public struct LapCount: Codable, Sendable {
    public var currentLap: Int?
    public var totalLaps: Int?

    enum CodingKeys: String, CodingKey {
        case currentLap = "CurrentLap"
        case totalLaps = "TotalLaps"
    }
}

extension LapCount {
    public static var empty: Self {
        .init(currentLap: 0, totalLaps: 0)
    }
}

extension LapCount {
    public mutating func merge(with delta: LapCount) {
        if let v = delta.currentLap { currentLap = v }
        if let v = delta.totalLaps { totalLaps = v }
    }
}
