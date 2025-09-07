import Foundation

public struct Message: Codable, Sendable {
    public let utc: String
    public let lap: Int?
    public let category: Category
    public let flag: Flag?
    public let scope: Scope?
    public let sector: Int?
    public let message: String
    public let status, mode, racingNumber: String?

    enum CodingKeys: String, CodingKey {
        case utc = "Utc"
        case lap = "Lap"
        case category = "Category"
        case flag = "Flag"
        case scope = "Scope"
        case sector = "Sector"
        case message = "Message"
        case status = "Status"
        case mode = "Mode"
        case racingNumber = "RacingNumber"
    }
}
