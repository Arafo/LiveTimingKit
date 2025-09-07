import Foundation

public struct Driver: Codable, Sendable {
    public var racingNumber: String?
    public var broadcastName: String?
    public var fullName: String?
    public var tla: String?
    public var line: Int
    public var teamName: String?
    public var teamColour: String?
    public var firstName: String?
    public var lastName: String?
    public var reference: String?
    public var headshotURL: String?
    public var publicIDRight: String?

    enum CodingKeys: String, CodingKey {
        case racingNumber = "RacingNumber"
        case broadcastName = "BroadcastName"
        case fullName = "FullName"
        case tla = "Tla"
        case line = "Line"
        case teamName = "TeamName"
        case teamColour = "TeamColour"
        case firstName = "FirstName"
        case lastName = "LastName"
        case reference = "Reference"
        case headshotURL = "HeadshotUrl"
        case publicIDRight = "PublicIdRight"
    }
}
