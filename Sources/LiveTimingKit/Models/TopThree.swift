import Foundation

public struct TopThree: Codable, Sendable {
    public let withheld: Bool
    public let lines: [LineElement]
    public let kf: Bool?

    enum CodingKeys: String, CodingKey {
        case withheld = "Withheld"
        case lines = "Lines"
        case kf = "_kf"
    }
}
