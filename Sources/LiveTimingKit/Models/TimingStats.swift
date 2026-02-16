import Foundation

public struct TimingStats: Codable, Sendable {
    public let withheld: Bool?
    var lines: [String: TimingStatsLine]
    public let sessionType: String?
    public let kf: Bool?

    enum CodingKeys: String, CodingKey {
        case withheld = "Withheld"
        case lines = "Lines"
        case sessionType = "SessionType"
        case kf = "_kf"
    }
}

extension TimingStats {
    public static var empty: Self { .init(withheld: false, lines: [:], sessionType: "", kf: false) }
}

extension TimingStats {
    public mutating func merge(with delta: TimingStats) {
        for (stat, newLine) in delta.lines {
            if var existing = lines[stat] {
                //if let v = newLine.racingNumber { existing.racingNumber = v }

                lines[stat] = existing
            } else {
                lines[stat] = newLine
            }
        }
    }
}
