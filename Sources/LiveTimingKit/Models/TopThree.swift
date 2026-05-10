import Foundation

public struct TopThree: Codable, Sendable {
    public var withheld: Bool?
    public var lines: [LineElement]
    public var kf: Bool?
    public var sessionPart: Int?

    enum CodingKeys: String, CodingKey {
        case withheld = "Withheld"
        case lines = "Lines"
        case kf = "_kf"
        case sessionPart = "SessionPart"
    }

    public init(
        withheld: Bool? = nil,
        lines: [LineElement] = [],
        kf: Bool? = nil,
        sessionPart: Int? = nil
    ) {
        self.withheld = withheld
        self.lines = lines
        self.kf = kf
        self.sessionPart = sessionPart
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        withheld = try container.decodeIfPresent(Bool.self, forKey: .withheld)
        kf = try container.decodeIfPresent(Bool.self, forKey: .kf)
        sessionPart = try container.decodeIfPresent(Int.self, forKey: .sessionPart)

        if let array = try? container.decode([LineElement].self, forKey: .lines) {
            lines = array
        } else if let dict = try? container.decode([String: LineElement].self, forKey: .lines) {
            lines = dict
                .sorted { (lhs, rhs) in (Int(lhs.key) ?? 0) < (Int(rhs.key) ?? 0) }
                .map { $0.value }
        } else {
            lines = []
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(withheld, forKey: .withheld)
        try container.encode(lines, forKey: .lines)
        try container.encodeIfPresent(kf, forKey: .kf)
        try container.encodeIfPresent(sessionPart, forKey: .sessionPart)
    }
}
