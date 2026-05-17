import Foundation

public struct ExtrapolatedClock: Codable, Sendable {
    public var utc: Date = Date.now
    public var remaining: String?
    public var extrapolating: Bool?
    public var hasUtc: Bool = false

    public init(
        utc: Date = Date.now,
        remaining: String?,
        extrapolating: Bool?,
        hasUtc: Bool = false
    ) {
        self.utc = utc
        self.remaining = remaining
        self.extrapolating = extrapolating
        self.hasUtc = hasUtc
    }

    enum CodingKeys: String, CodingKey {
        case utc = "Utc"
        case remaining = "Remaining"
        case extrapolating = "Extrapolating"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let utcString = try container.decodeIfPresent(String.self, forKey: .utc)
        self.utc = utcString.flatMap(Self.parseUTC) ?? Date.now
        self.hasUtc = utcString != nil
        self.remaining = try container.decodeIfPresent(String.self, forKey: .remaining)
        self.extrapolating = try container.decodeIfPresent(Bool.self, forKey: .extrapolating)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if hasUtc {
            try container.encode(Self.formatUTC(utc), forKey: .utc)
        }
        try container.encodeIfPresent(remaining, forKey: .remaining)
        try container.encodeIfPresent(extrapolating, forKey: .extrapolating)
    }

    private static func parseUTC(_ value: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: value) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return ISO8601DateFormatter().date(from: value)
    }

    private static func formatUTC(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}

extension ExtrapolatedClock {
    public static var empty: Self {
        .init(remaining: nil, extrapolating: nil)
    }
}

extension ExtrapolatedClock {
    public mutating func merge(with delta: ExtrapolatedClock) {
        if delta.hasUtc {
            utc = delta.utc
            hasUtc = true
        }
        if let value = delta.remaining { remaining = value }
        if let value = delta.extrapolating { extrapolating = value }
    }
}
