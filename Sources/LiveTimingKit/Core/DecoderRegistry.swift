import Foundation

public final class DecoderRegistry {
    private var decoders: [Topic: any TopicDecoder] = [:]

    public init() {}

    public func register(_ decoder: any TopicDecoder, for topic: Topic) {
        decoders[topic] = decoder
    }

    public func decoder(for topic: Topic) -> (any TopicDecoder)? {
        decoders[topic]
    }
}

public extension DecoderRegistry {
    func register<Model: Decodable>(_ type: Model.Type, for topic: Topic) {
        register(JSONTopicDecoder<Model>(), for: topic)
    }
}
