import Foundation

public struct TimingData: Codable, Sendable {
    public var lines: [String: TimingDataLine]
    public let withheld: Bool?
    public let kf: Bool?

    enum CodingKeys: String, CodingKey {
        case lines = "Lines"
        case withheld = "Withheld"
        case kf = "_kf"
    }
}

extension TimingData {
    public static var empty: Self { .init(lines: [:], withheld: false, kf: false) }
}

extension TimingData {
    public mutating func merge(with delta: TimingData) {
        for (car, newLine) in delta.lines {
            if var existing = lines[car] {
                if let v = newLine.lastLapTime { existing.lastLapTime = v }
                if let v = newLine.bestLapTime { existing.bestLapTime = v }
                if let v = newLine.gapToLeader { existing.gapToLeader = v }
                if let v = newLine.position { existing.position = v }
                if let v = newLine.intervalToPositionAhead { existing.intervalToPositionAhead = v }
                if let v = newLine.inPit { existing.inPit = v }
                if let v = newLine.retired { existing.retired = v }
                if let v = newLine.showPosition { existing.showPosition = v }
                if let v = newLine.racingNumber { existing.racingNumber = v }
                if let v = newLine.pitOut { existing.pitOut = v }
                if let v = newLine.stopped { existing.stopped = v }
                if let v = newLine.status { existing.status = v }
                if let v = newLine.sectors { existing.sectors = v }
                //if let v = newLine.sectors { existing.sectors?.merge(with: v) }
                if let v = newLine.speeds { existing.speeds = v }
                if let v = newLine.sectors { existing.sectors = v }
                if let v = newLine.sectors { existing.sectors = v }
                if let v = newLine.numberOfLaps { existing.numberOfLaps = v }
                if let v = newLine.numberOfPitStops { existing.numberOfPitStops = v }
                lines[car] = existing
            } else {
                lines[car] = newLine
            }
        }
    }
}
