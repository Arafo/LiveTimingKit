import Foundation

struct BestSector: Codable, Sendable {
    let value: String
    let position: Int?

    enum CodingKeys: String, CodingKey {
        case value = "Value"
        case position = "Position"
    }
}
