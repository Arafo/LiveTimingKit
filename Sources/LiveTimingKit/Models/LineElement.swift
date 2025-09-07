import Foundation

public struct LineElement: Codable, Sendable {
    public var position: String?
    public var showPosition: Bool?
    public var racingNumber: String?
    public var tla: String?
    public var broadcastName: String?
    public var fullName: String?
    public var firstName: String?
    public var lastName: String?
    public var reference: String?
    public var team: String?
    public var teamColour: String?
    public var lapTime: String?
    public var lapState: Int?
    public var diffToAhead: String?
    public var diffToLeader: String?
    public var overallFastest: Bool?
    public var personalFastest: Bool?

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
