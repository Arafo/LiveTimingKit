import Foundation
import LiveTimingModels

// The `to(_:encoder:decoder:)` method on `AnyCodable` is `internal` in LiveTimingModels.
// Provide a public bridge so LiveTimingKit (and its consumers) can convert payloads.
extension AnyCodable {
    public func decode<T: Decodable>(
        _ type: T.Type,
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
    ) throws -> T {
        // For dictionary/array values (the normal SignalR payload path), use
        // JSONSerialization to avoid Swift 6 Sendable issues with _AnyEncodable.
        let sanitized = Self.liveTiming_sanitize(value)
        if JSONSerialization.isValidJSONObject(sanitized) {
            let data = try JSONSerialization.data(withJSONObject: sanitized, options: .fragmentsAllowed)
            return try decoder.decode(T.self, from: data)
        }
        // For primitive or Encodable-wrapped values, fall back to JSONEncoder.
        let data = try encoder.encode(self)
        return try decoder.decode(T.self, from: data)
    }

    private static func liveTiming_sanitize(_ value: Any) -> Any {
        switch value {
        case is Void:
            return NSNull()
        case let bool as Bool:
            return bool
        case let uint as UInt:
            return Int(uint)
        case let int as Int:
            return int
        case let double as Double:
            return double
        case let string as String:
            return string
        case let array as [Any]:
            return array.map { liveTiming_sanitize($0) }
        case let dict as [String: Any]:
            return dict.mapValues { liveTiming_sanitize($0) }
        default:
            return value
        }
    }
}
