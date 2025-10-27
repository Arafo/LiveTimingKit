import Foundation

public struct SessionInfo: Codable, Sendable {
    public var meeting: Meeting?
    public var sessionStatus: String?
    public var archiveStatus: ArchiveStatus?
    public var key: Int?
    public var type: String?
    public var number: Int?
    public var name: String?
    public var startDate: String?
    public var endDate: String?
    public var gmtOffset: String?
    public var path: String?
    public var kf: Bool?
    public var circuitPoints: [CircuitPoint]?
    public var circuitCorners: [CircuitCorner]?
    public var circuitRotation: Int?

    enum CodingKeys: String, CodingKey {
        case meeting = "Meeting"
        case sessionStatus = "SessionStatus"
        case archiveStatus = "ArchiveStatus"
        case key = "Key"
        case type = "Type"
        case number = "Number"
        case name = "Name"
        case startDate = "StartDate"
        case endDate = "EndDate"
        case gmtOffset = "GmtOffset"
        case path = "Path"
        case kf = "_kf"
        case circuitPoints = "CircuitPoints"
        case circuitCorners = "CircuitCorners"
        case circuitRotation = "CircuitRotation"
    }
}

public extension SessionInfo {
    struct CircuitPoint: Codable, Sendable {
        public var x: Int?
        public var y: Int?

        public init(x: Int? = nil, y: Int? = nil) {
            self.x = x
            self.y = y
        }

        private enum CodingKeys: String, CodingKey {
            case x = "X"
            case y = "Y"
        }

        public init(from decoder: Decoder) throws {
            if var container = try? decoder.unkeyedContainer() {
                x = try? container.decode(Int.self)
                y = try? container.decode(Int.self)
            } else {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                x = try container.decodeIfPresent(Int.self, forKey: .x)
                y = try container.decodeIfPresent(Int.self, forKey: .y)
            }
        }

        public func encode(to encoder: Encoder) throws {
            if let x, let y {
                var container = encoder.unkeyedContainer()
                try container.encode(x)
                try container.encode(y)
            } else {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encodeIfPresent(x, forKey: .x)
                try container.encodeIfPresent(y, forKey: .y)
            }
        }
    }

    struct CircuitCorner: Codable, Sendable {
        public var number: Int?
        public var x: Double?
        public var y: Double?

        public init(number: Int? = nil, x: Double? = nil, y: Double? = nil) {
            self.number = number
            self.x = x
            self.y = y
        }

        private enum CodingKeys: String, CodingKey {
            case number = "Number"
            case x = "X"
            case y = "Y"
        }

        public init(from decoder: Decoder) throws {
            if var container = try? decoder.unkeyedContainer() {
                number = try? container.decode(Int.self)
                x = try? container.decode(Double.self)
                y = try? container.decode(Double.self)
            } else {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                number = try container.decodeIfPresent(Int.self, forKey: .number)
                x = try container.decodeIfPresent(Double.self, forKey: .x)
                y = try container.decodeIfPresent(Double.self, forKey: .y)
            }
        }

        public func encode(to encoder: Encoder) throws {
            if let number, let x, let y {
                var container = encoder.unkeyedContainer()
                try container.encode(number)
                try container.encode(x)
                try container.encode(y)
            } else {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encodeIfPresent(number, forKey: .number)
                try container.encodeIfPresent(x, forKey: .x)
                try container.encodeIfPresent(y, forKey: .y)
            }
        }
    }
}
