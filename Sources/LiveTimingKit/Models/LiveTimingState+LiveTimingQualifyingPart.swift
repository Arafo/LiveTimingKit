import Foundation

public extension LiveTimingState {
    var liveTimingQualifyingPart: LiveTimingQualifyingPart? {
        let parts = [
            timingData.sessionPart,
            topThree?.sessionPart
        ] + (sessionData?.series.map(\.qualifyingPart) ?? [])

        return parts
            .compactMap { $0.flatMap(LiveTimingQualifyingPart.init(rawValue:)) }
            .max { $0.rawValue < $1.rawValue }
    }
}
