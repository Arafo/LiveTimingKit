import Foundation

public struct SessionInfo: Codable, Sendable {
    public let meeting: Meeting
    public let sessionStatus: String
    public let archiveStatus: ArchiveStatus
    public let key: Int
    public let type, name, startDate, endDate: String
    public let gmtOffset, path: String
    public let kf: Bool?

    enum CodingKeys: String, CodingKey {
        case meeting = "Meeting"
        case sessionStatus = "SessionStatus"
        case archiveStatus = "ArchiveStatus"
        case key = "Key"
        case type = "Type"
        case name = "Name"
        case startDate = "StartDate"
        case endDate = "EndDate"
        case gmtOffset = "GmtOffset"
        case path = "Path"
        case kf = "_kf"
    }
}
