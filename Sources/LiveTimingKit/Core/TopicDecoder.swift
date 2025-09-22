import Foundation

public protocol TopicDecoder {
    func decode(_ data: Data, using decoder: JSONDecoder) throws -> Any
}

public struct JSONTopicDecoder<Model: Decodable>: TopicDecoder {
    public init() {}

    public func decode(_ data: Data, using decoder: JSONDecoder) throws -> Any {
        try decoder.decode(Model.self, from: data)
    }
}
