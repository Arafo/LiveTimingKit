
public struct CarData: Codable, Sendable {
    public var entries: [String: CarEntry]

    enum CodingKeys: String, CodingKey {
        case entries = "Entries"
    }
}

extension CarData {
    public static var empty: Self { .init(entries: [:]) }
}


public struct CarEntry: Codable, Sendable {
    public var speed: Double?
    public var rpm: Double?
    public var gear: Int?
    public var throttle: Double?
    public var brake: Bool?

    enum CodingKeys: String, CodingKey {
        case speed = "Speed"
        case rpm = "RPM"
        case gear = "nGear"
        case throttle = "Throttle"
        case brake = "Brake"
    }
}

extension CarData {
    public mutating func merge(with delta: CarData) {
        for (car, newEntry) in delta.entries {
            if var existing = entries[car] {
                if let v = newEntry.speed { existing.speed = v }
                if let v = newEntry.rpm { existing.rpm = v }
                if let v = newEntry.gear { existing.gear = v }
                if let v = newEntry.throttle { existing.throttle = v }
                if let v = newEntry.brake { existing.brake = v }
                entries[car] = existing
            } else {
                entries[car] = newEntry
            }
        }
    }
}
