import Foundation

public struct Meeting: Codable, Sendable {
    public var key: Int?
    public var name: String?
    public var officialName: String?
    public var location: String?
    public var number: Int?
    public var country: Country?
    public var circuit: Circuit?

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
