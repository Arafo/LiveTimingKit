import Foundation

public struct TeamRadio: Codable, Sendable {
    public let captures: [Capture]

    enum CodingKeys: String, CodingKey {
        case captures = "Captures"
    }
}
