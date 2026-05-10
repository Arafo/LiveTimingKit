import Foundation

public enum LiveTimingSessionKind: Sendable, Equatable {
    case practice(Int?)
    case qualifying
    case sprintQualifying
    case race
    case sprint
    case unknown
}
