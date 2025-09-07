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
                if let v = newLine.stints { existing.stints = v }
                lines[car] = existing
            } else {
                lines[car] = newLine
            }
        }
    }
}
