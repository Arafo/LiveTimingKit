import Foundation

public struct Speeds: Codable, Sendable {
    public let i1: LastLapTime?
    public let i2: LastLapTime?
    public let fl: LastLapTime?
    public let st: LastLapTime?

    enum CodingKeys: String, CodingKey {
        case i1 = "I1"
        case i2 = "I2"
        case fl = "FL"
        case st = "ST"
    }
}
