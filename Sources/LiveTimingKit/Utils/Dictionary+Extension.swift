import Foundation

extension AnyCodable {
    
    func to<T: Decodable>(
        _ type: T.Type,
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
    ) throws -> T {
        let data = try encoder.encode(self)
        return try decoder.decode(T.self, from: data)
    }
}

extension Dictionary where Key == String, Value == AnyCodable {
    public func to<T: Decodable>(
        _ type: T.Type,
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
    ) throws -> T {
        let wrapper = AnyCodableWrapper(dictionary: self)
        let data = try encoder.encode(wrapper.dictionary)
        return try decoder.decode(type, from: data)
    }
}

extension String {
    public func to<T: Decodable>(
        _ type: T.Type,
        decoder: JSONDecoder = .init(),
        encoding: String.Encoding = .utf8
    ) throws -> T {
        guard let data = try self.data(using: encoding) else {
            fatalError()
        }
        return try decoder.decode(type, from: data)
    }
}
