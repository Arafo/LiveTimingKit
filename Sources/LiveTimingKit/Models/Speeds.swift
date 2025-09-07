import Foundation

public struct Speeds: Codable, Sendable {
    public let i1, i2, fl, st: LastLapTime

    enum CodingKeys: String, CodingKey {
        case i1 = "I1"
        case i2 = "I2"
        case fl = "FL"
        case st = "ST"
    }
}
