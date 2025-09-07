import Foundation

public struct TimingStats: Codable, Sendable {
    let withheld: Bool
    let lines: [String: TimingStatsLine]
    let sessionType: String
    let kf: Bool

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
