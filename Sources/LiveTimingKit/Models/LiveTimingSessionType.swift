import Foundation

public enum LiveTimingSessionType: String, Codable, Sendable, Equatable {
    case practice = "Practice"
    case qualifying = "Qualifying"
    case race = "Race"
}
