import Foundation

public struct Driver: Codable, Sendable {
    public let racingNumber, broadcastName, fullName, tla: String
    public let line: Int
    public let teamName, teamColour, firstName, lastName: String
    public let reference: String
    public let headshotURL: String?
    public let publicIDRight: String

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
