import Foundation

public struct TimingAppData: Codable, Sendable {
    public var lines: [String: TimingAppDataLine]

    enum CodingKeys: String, CodingKey {
        case lines = "Lines"
    }
}

extension TimingAppData {
    public mutating func merge(with delta: TimingAppData) {
        for (car, newLine) in delta.lines {
            if var existing = lines[car] {
                if let v = newLine.racingNumber { existing.racingNumber = v }
                if let v = newLine.line { existing.line = v }
                if let v = newLine.gridPos { existing.gridPos = v }
                if let v = newLine.stints {
                    existing.stints = mergeStints(existing: existing.stints, delta: v)
                }
                lines[car] = existing
            } else {
                lines[car] = newLine
            }
        }
    }

    private func mergeStints(
        existing: [String: LineStint]?,
        delta: [String: LineStint]
    ) -> [String: LineStint] {
        guard var merged = existing else { return delta }

        for (index, deltaStint) in delta {
            if let existingStint = merged[index] {
                merged[index] = mergeLineStint(existing: existingStint, delta: deltaStint)
            } else {
                merged[index] = deltaStint
            }
        }

        return merged
    }

    /// Merges non-nil fields from `delta` into `existing`, preserving existing values
    /// when the incoming delta omits them.
    private func mergeLineStint(existing: LineStint, delta: LineStint) -> LineStint {
        LineStint(
            lapFlags: delta.lapFlags ?? existing.lapFlags,
            compound: delta.compound ?? existing.compound,
            new: delta.new ?? existing.new,
            tyresNotChanged: delta.tyresNotChanged ?? existing.tyresNotChanged,
            totalLaps: delta.totalLaps ?? existing.totalLaps,
            startLaps: delta.startLaps ?? existing.startLaps,
            lapTime: delta.lapTime ?? existing.lapTime,
            lapNumber: delta.lapNumber ?? existing.lapNumber
        )
    }
}
