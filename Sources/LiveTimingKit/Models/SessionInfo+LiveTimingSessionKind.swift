import Foundation

public extension SessionInfo {
    var liveTimingSessionType: LiveTimingSessionType? {
        type.flatMap(LiveTimingSessionType.init(rawValue:))
    }

    var liveTimingSessionKind: LiveTimingSessionKind {
        switch liveTimingSessionType {
        case .practice:
            .practice(number)
        case .qualifying:
            normalizedSessionName == "Sprint Qualifying" ? .sprintQualifying : .qualifying
        case .race:
            normalizedSessionName == "Sprint" ? .sprint : .race
        case nil:
            .unknown
        }
    }

    private var normalizedSessionName: String? {
        name?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
