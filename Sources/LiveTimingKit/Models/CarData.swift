import Foundation

public struct CarData: Codable, Sendable {
    public var entries: [CarDataEntry]

    public init(entries: [CarDataEntry]) {
        self.entries = entries
    }

    enum CodingKeys: String, CodingKey {
        case entries = "Entries"
    }
}

public struct CarDataEntry: Codable, Sendable {
    public var utc: String
    public var cars: [String: CarDataEntryCar]

    public init(utc: String, cars: [String: CarDataEntryCar]) {
        self.utc = utc
        self.cars = cars
    }

    enum CodingKeys: String, CodingKey {
        case utc = "Utc"
        case cars = "Cars"
    }
}

public struct CarDataEntryCar: Codable, Sendable {
    public var channels: CarDataEntryCarChannel

    public init(channels: CarDataEntryCarChannel) {
        self.channels = channels
    }

    enum CodingKeys: String, CodingKey {
        case channels = "Channels"
    }
}

public struct CarDataEntryCarChannel: Codable, Sendable {
    public var rpm: Int?
    public var speed: Int?
    public var ngear: Int?
    public var throttle: Int?
    public var brake: Int?
    public var drs: Int?

    public init(
        rpm: Int? = nil,
        speed: Int? = nil,
        ngear: Int? = nil,
        throttle: Int? = nil,
        brake: Int? = nil,
        drs: Int? = nil
    ) {
        self.rpm = rpm
        self.speed = speed
        self.ngear = ngear
        self.throttle = throttle
        self.brake = brake
        self.drs = drs
    }

    enum CodingKeys: String, CodingKey {
        case rpm = "0"
        case speed = "2"
        case ngear = "3"
        case throttle = "4"
        case brake = "5"
        case drs = "45"
    }
}

extension CarData {
    public static var empty: Self { .init(entries: []) }
}

extension CarData {
    public mutating func merge(with delta: CarData) {
        entries.append(contentsOf: delta.entries)
        if let latest = entries.last {
            entries = [latest]
        }
    }
}
