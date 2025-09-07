import Foundation

public struct Meeting: Codable, Sendable {
    public let key: Int
    public let name, officialName, location: String
    public let number: Int
    public let country: Country
    public let circuit: Circuit

    enum CodingKeys: String, CodingKey {
        case key = "Key"
        case name = "Name"
        case officialName = "OfficialName"
        case location = "Location"
        case number = "Number"
        case country = "Country"
        case circuit = "Circuit"
    }
}
