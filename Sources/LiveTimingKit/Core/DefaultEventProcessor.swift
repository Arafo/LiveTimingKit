import Foundation

public final actor DefaultEventProcessor: EventProcessor {
    public enum Error: Swift.Error, Equatable {
        case invalidTopic(String)
        case decodingFailed(topic: Topic, underlyingDescription: String)
        case publishFailed(topic: Topic, underlyingDescription: String)
    }

    private let bus: EventBus
    private let registry: DecoderRegistry
    private let decoder: JSONDecoder

    public init(
        bus: EventBus,
        registry: DecoderRegistry,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.bus = bus
        self.registry = registry
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    public func process(_ event: RawEvent) async throws {
        guard let topic = Topic(rawValue: event.topic) else {
            throw Error.invalidTopic(event.topic)
        }

        guard let topicDecoder = registry.decoder(for: topic) else {
            return
        }

        do {
            let payload = try topicDecoder.decode(event.payload, using: decoder)

            do {
                try await bus.publish(topic: topic, payload: payload)
            } catch {
                throw Error.publishFailed(topic: topic, underlyingDescription: String(describing: error))
            }
        } catch {
            if let processorError = error as? Error {
                throw processorError
            }

            throw Error.decodingFailed(topic: topic, underlyingDescription: String(describing: error))
        }
    }
}
