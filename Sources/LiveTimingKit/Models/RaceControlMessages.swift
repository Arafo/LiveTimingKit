import Foundation

public struct RaceControlMessages: Codable, Sendable {
    public var messages: [String: Message]
    public var kf: Bool?

    public init(messages: [String: Message], kf: Bool? = nil) {
        self.messages = messages
        self.kf = kf
    }

    enum CodingKeys: String, CodingKey {
        case messages = "Messages"
        case kf = "_kf"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kf = try container.decodeIfPresent(Bool.self, forKey: .kf)

        if let dict = try? container.decode([String: Message].self, forKey: .messages) {
            messages = dict
        } else if let array = try? container.decode([Message].self, forKey: .messages) {
            messages = Dictionary(
                uniqueKeysWithValues: array.enumerated().map { (String($0.offset), $0.element) }
            )
        } else {
            messages = [:]
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messages, forKey: .messages)
        try container.encodeIfPresent(kf, forKey: .kf)
    }
}

extension RaceControlMessages {
    public mutating func merge(with delta: RaceControlMessages) {
        for (key, message) in delta.messages {
            messages[key] = message
        }
        if let value = delta.kf { kf = value }
    }
}
