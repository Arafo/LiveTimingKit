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

    /// Deep-merges incoming stint data into the existing stints, preserving fields
    /// (such as `compound`) that are absent from the delta.
    ///
    /// - When the delta is an `.array`, each element at the same position is merged
    ///   field-by-field; extra delta elements beyond the existing array are appended.
    /// - When the delta is a `.dictionary`, each key is merged individually into the
    ///   corresponding existing key (or inserted if new).
    /// - When there are no existing stints the delta is stored verbatim.
    private func mergeStints(
        existing: TimingAppDataLineStint?,
        delta: TimingAppDataLineStint
    ) -> TimingAppDataLineStint {
        guard let existing else { return delta }

        switch (existing, delta) {

        case (.array(let existingArray), .array(let deltaArray)):
            var merged = existingArray
            for (idx, deltaStint) in deltaArray.enumerated() {
                if idx < merged.count {
                    merged[idx] = mergeLineStint(existing: merged[idx], delta: deltaStint)
                } else {
                    merged.append(deltaStint)
                }
            }
            return .array(merged)

        case (.dictionary(let existingDict), .dictionary(let deltaDict)):
            var merged = existingDict
            for (key, deltaStint) in deltaDict {
                if let existingStint = merged[key] {
                    merged[key] = mergeLineStint(existing: existingStint, delta: deltaStint)
                } else {
                    merged[key] = deltaStint
                }
            }
            return .dictionary(merged)

        // Mixed cases: delta format differs from existing — prefer the delta's
        // representation but carry over data from the existing stints where possible.

        case (.array(let existingArray), .dictionary(let deltaDict)):
            // Build a merged dictionary, seeding from the existing array indices.
            var merged: [String: LineStint] = Dictionary(
                uniqueKeysWithValues: existingArray.enumerated().map { ("\($0.offset)", $0.element) }
            )
            for (key, deltaStint) in deltaDict {
                if let existingStint = merged[key] {
                    merged[key] = mergeLineStint(existing: existingStint, delta: deltaStint)
                } else {
                    merged[key] = deltaStint
                }
            }
            return .dictionary(merged)

        case (.dictionary(let existingDict), .array(let deltaArray)):
            // Build a merged array ordered by existing dict keys.
            let sortedKeys = existingDict.keys.sorted {
                (Int($0) ?? Int.min) < (Int($1) ?? Int.min)
            }
            var existingArray = sortedKeys.compactMap { existingDict[$0] }
            for (idx, deltaStint) in deltaArray.enumerated() {
                if idx < existingArray.count {
                    existingArray[idx] = mergeLineStint(existing: existingArray[idx], delta: deltaStint)
                } else {
                    existingArray.append(deltaStint)
                }
            }
            return .array(existingArray)
        }
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
