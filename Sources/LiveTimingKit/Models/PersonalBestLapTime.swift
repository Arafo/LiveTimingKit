import Foundation

struct PersonalBestLapTime: Codable, Sendable {
    let value: String?
    let lap: Int?
    let position: Int?

    enum CodingKeys: String, CodingKey {
        case value = "Value"
        case lap = "Lap"
        case position = "Position"
    }
}
