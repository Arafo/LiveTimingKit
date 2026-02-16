import Foundation

public struct TimingStats: Codable, Sendable {
    let withheld: Bool?
    var lines: [String: TimingStatsLine]
    let sessionType: String?
    let kf: Bool?

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
            // TimingStatsLine currently represents full line snapshots for each key.
            // Replace the existing line so incoming deltas are not silently ignored.
            lines[stat] = newLine
        }
    }
}
