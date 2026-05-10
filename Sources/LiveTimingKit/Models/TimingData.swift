import Foundation

public struct TimingData: Codable, Sendable {
    public var lines: [String: TimingDataLine]
    public var withheld: Bool?
    public var kf: Bool?
    public var sessionPart: Int?

    public init(
        lines: [String: TimingDataLine],
        withheld: Bool? = nil,
        kf: Bool? = nil,
        sessionPart: Int? = nil
    ) {
        self.lines = lines
        self.withheld = withheld
        self.kf = kf
        self.sessionPart = sessionPart
    }

    enum CodingKeys: String, CodingKey {
        case lines = "Lines"
        case withheld = "Withheld"
        case kf = "_kf"
        case sessionPart = "SessionPart"
    }
}

extension TimingData {
    public static var empty: Self { .init(lines: [:], withheld: nil, kf: nil) }
}

extension TimingData {
    public mutating func merge(with delta: TimingData) {
        for (car, update) in delta.lines {
            if var existing = lines[car] {
                existing.merge(with: update)
                lines[car] = existing
            } else {
                lines[car] = update
            }
        }

        if let value = delta.withheld { withheld = value }
        if let value = delta.kf { kf = value }
        if let value = delta.sessionPart { sessionPart = value }
    }
}
