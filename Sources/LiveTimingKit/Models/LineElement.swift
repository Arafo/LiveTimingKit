import Foundation

public struct LineElement: Codable, Sendable {
    public let position: String
    public let showPosition: Bool
    public let racingNumber, tla, broadcastName, fullName: String
    public let firstName, lastName, reference, team: String
    public let teamColour, lapTime: String
    public let lapState: Int
    public let diffToAhead, diffToLeader: String
    public let overallFastest, personalFastest: Bool

    enum CodingKeys: String, CodingKey {
        case position = "Position"
        case showPosition = "ShowPosition"
        case racingNumber = "RacingNumber"
        case tla = "Tla"
        case broadcastName = "BroadcastName"
        case fullName = "FullName"
        case firstName = "FirstName"
        case lastName = "LastName"
        case reference = "Reference"
        case team = "Team"
        case teamColour = "TeamColour"
        case lapTime = "LapTime"
        case lapState = "LapState"
        case diffToAhead = "DiffToAhead"
        case diffToLeader = "DiffToLeader"
        case overallFastest = "OverallFastest"
        case personalFastest = "PersonalFastest"
    }
}
