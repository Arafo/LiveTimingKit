import Foundation

public enum StringDecodingError: Error {
    case unableToEncode(String, encoding: String.Encoding)
}

extension StringDecodingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .unableToEncode(string, encoding):
            return "Unable to encode \(string) using encoding \(encoding)."
        }
    }
}

extension AnyCodable {

    func to<T: Decodable>(
        _ type: T.Type,
        encoder: JSONEncoder,
        decoder: JSONDecoder
    ) throws -> T {
        let data = try encoder.encode(self)
        return try decoder.decode(T.self, from: data)
    }
}

extension Dictionary where Key == String, Value == AnyCodable {
    public func to<T: Decodable>(
        _ type: T.Type,
        encoder: JSONEncoder,
        decoder: JSONDecoder
    ) throws -> T {
        let wrapper = AnyCodableWrapper(dictionary: self)
        let data = try encoder.encode(wrapper.dictionary)
        return try decoder.decode(type, from: data)
    }
}

extension String {
    public func to<T: Decodable>(
        _ type: T.Type,
        decoder: JSONDecoder,
        encoding: String.Encoding = .utf8
    ) throws -> T {
        guard let data = self.data(using: encoding) else {
            throw StringDecodingError.unableToEncode(self, encoding: encoding)
        }
        return try decoder.decode(type, from: data)
    }
}
