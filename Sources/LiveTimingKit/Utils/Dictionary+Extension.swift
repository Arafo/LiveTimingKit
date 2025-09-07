import Foundation

extension Dictionary where Key == String, Value == AnyCodable {
    func to<T: Decodable>(
        _ type: T.Type,
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
    ) throws -> T {
        let wrapper = AnyCodableWrapper(dictionary: self)
        let data = try encoder.encode(wrapper.dictionary)
        return try decoder.decode(type, from: data)
    }
}
