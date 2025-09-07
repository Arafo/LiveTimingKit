import Foundation

public struct PositionZ: Codable, Sendable {
    public var position: [PositionData]

    enum CodingKeys: String, CodingKey {
        case position = "Position"
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
