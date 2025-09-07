import Foundation

struct BestSpeeds: Codable, Sendable {
    let i1: BestSector?
    let i2: BestSector?
    let fl: BestSector?
    let st: BestSector?

    enum CodingKeys: String, CodingKey {
        case i1 = "I1"
        case i2 = "I2"
        case fl = "FL"
        case st = "ST"
    }
}
