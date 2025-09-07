import Foundation

public struct TeamRadio: Codable, Sendable {
    public let captures: [Capture]
    public let kf: Bool

    enum CodingKeys: String, CodingKey {
        case captures = "Captures"
        case kf = "_kf"
    }
}
