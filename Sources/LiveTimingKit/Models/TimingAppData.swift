import Foundation

public struct TimingAppData: Codable, Sendable {
    public let lines: [String: TimingAppDataLine]
    public let kf: Bool

    enum CodingKeys: String, CodingKey {
        case lines = "Lines"
        case kf = "_kf"
    }
}
