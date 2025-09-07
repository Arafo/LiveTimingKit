
public struct PositionData: Codable, Sendable {
    public var entries: [String: PositionEntry]

    enum CodingKeys: String, CodingKey {
        case entries = "Position"
    }
}

extension PositionData {
    public static var empty: Self { .init(entries: [:]) }
}

public struct PositionEntry: Codable, Sendable {
    public var x: Double?
    public var y: Double?
    public var z: Double?

    enum CodingKeys: String, CodingKey {
        case x = "X"; case y = "Y"; case z = "Z"
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
