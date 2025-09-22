import Foundation

public struct RawEvent: Codable, Sendable {
    public let topic: String
    public let payload: Data
    public let timestamp: Date

    public init(topic: String, payload: Data, timestamp: Date) {
        self.topic = topic
        self.payload = payload
        self.timestamp = timestamp
    }
}
