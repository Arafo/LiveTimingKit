import Foundation
import SWCompression

public struct PositionZ: Codable, Sendable {
    public var position: [PositionData]

    enum CodingKeys: String, CodingKey {
        case position = "Position"
    }
    
    public init(position: [PositionData]) {
        self.position = position
    }

    public init(from decoder: any Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            self.position = try container.decode([PositionData].self, forKey: .position)
        } else {
            let container = try decoder.singleValueContainer()
            let encodedData = try container.decode(String.self)

            guard let decodedData = Data(base64Encoded: encodedData) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Position.z payload is not valid base64."
                )
            }

            let decompressedData = try Deflate.decompress(data: decodedData)
            let decompressedString = String(data: decompressedData, encoding: .utf8)

            do {
                if let dict = try decompressedString?.to(PositionZ.self, decoder: JSONDecoder()) {
                    self.position = dict.position
                } else {
                    self.position = []
                }
            } catch {
                self.position = []
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(position, forKey: .position)
    }
}

extension PositionZ {
    public static var empty: Self { .init(position: []) }
}

extension PositionZ {
    public mutating func merge(with delta: PositionZ) {
        position = delta.position
        //position.append(contentsOf: delta.position)
    }
}


public struct PositionData: Codable, Sendable {
    public var timestamp: String
    public var entries: [String: PositionEntry]

    enum CodingKeys: String, CodingKey {
        case timestamp = "Timestamp"
        case entries = "Entries"
    }

    public init(timestamp: String = "", entries: [String: PositionEntry] = [:]) {
        self.timestamp = timestamp
        self.entries = entries
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = try container.decodeIfPresent(String.self, forKey: .timestamp) ?? ""
        entries = try container.decodeIfPresent([String: PositionEntry].self, forKey: .entries) ?? [:]
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        if !entries.isEmpty {
            try container.encode(entries, forKey: .entries)
        }
    }
}

//extension PositionData {
//    public static var empty: Self { .init(entries: [:]) }
//}

public struct PositionEntry: Codable, Sendable {
    public let status: String?
    public var x: Double?
    public var y: Double?
    public var z: Double?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case x = "X"
        case y = "Y"
        case z = "Z"
    }
}

extension PositionData {
    public mutating func merge(with delta: PositionData) {
        for (car, newPos) in delta.entries {
            if var existing = entries[car] {
                if let v = newPos.x { existing.x = v }
                if let v = newPos.y { existing.y = v }
                if let v = newPos.z { existing.z = v }
                entries[car] = existing
            } else {
                entries[car] = newPos
            }
        }
    }
}
