import Foundation

public struct DriverList: Codable, Sendable {
    public init(drivers: [String : Driver], kf: Bool) {
        self.drivers = drivers
        self.kf = kf
    }
    
    public var drivers: [String: Driver]
    public let kf: Bool

    private struct KFKey: CodingKey {
        var stringValue: String
        var intValue: Int? { nil }
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        init?(intValue: Int) {
            nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: KFKey.self)
        var map: [String: Driver] = [:]
        var kfValue = false
        for key in container.allKeys {
            if key.stringValue == "_kf" {
                kfValue = try container.decode(Bool.self, forKey: key)
            } else {
                let driver = try container.decode(Driver.self, forKey: key)
                if map[key.stringValue] == nil {
                    map[key.stringValue] = driver
                }
                if driver.racingNumber != nil {
                    map[key.stringValue]?.racingNumber = driver.racingNumber
                }
                if driver.broadcastName != nil {
                    map[key.stringValue]?.broadcastName = driver.broadcastName
                }
                if driver.fullName != nil {
                    map[key.stringValue]?.fullName = driver.fullName
                }
                if driver.tla != nil {
                    map[key.stringValue]?.tla = driver.tla
                }
                if let line = driver.line {
                    map[key.stringValue]?.line = line
                }
                if driver.teamName != nil {
                    map[key.stringValue]?.teamName = driver.teamName
                }
                if driver.teamColour != nil {
                    map[key.stringValue]?.teamColour = driver.teamColour
                }
                if driver.firstName != nil {
                    map[key.stringValue]?.firstName = driver.firstName
                }
                if driver.lastName != nil {
                    map[key.stringValue]?.lastName = driver.lastName
                }
                if driver.reference != nil {
                    map[key.stringValue]?.reference = driver.reference
                }
                if driver.headshotURL != nil {
                    map[key.stringValue]?.headshotURL = driver.headshotURL
                }
                if driver.publicIDRight != nil {
                    map[key.stringValue]?.publicIDRight = driver.publicIDRight
                }
                if driver.isSelected != nil {
                    map[key.stringValue]?.isSelected = driver.isSelected
                } else if map[key.stringValue]?.isSelected == nil {
                    map[key.stringValue]?.isSelected = true
                }
            }
        }
        self.drivers = map
        self.kf = kfValue
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: KFKey.self)
        for (key, value) in drivers {
            guard let codingKey = KFKey(stringValue: key) else { continue }
            try container.encode(value, forKey: codingKey)
        }
        if let kfKey = KFKey(stringValue: "_kf") {
            try container.encode(kf, forKey: kfKey)
        }
    }
}

extension DriverList {
    public static var empty: Self {
        .init(drivers: [:], kf: false)
    }
}

extension DriverList {
    public mutating func merge(with delta: DriverList) {
        for (driver, newLine) in delta.drivers {
            if var existing = drivers[driver] {
                if let v = newLine.racingNumber { existing.racingNumber = v }
                if let v = newLine.broadcastName { existing.broadcastName = v }
                if let v = newLine.fullName { existing.fullName = v }
                if let v = newLine.tla { existing.tla = v }
                if let v = newLine.teamName { existing.teamName = v }
                if let v = newLine.teamColour { existing.teamColour = v }
                if let v = newLine.firstName { existing.firstName = v }
                if let v = newLine.lastName { existing.lastName = v }
                if let v = newLine.reference { existing.reference = v }
                if let v = newLine.headshotURL { existing.headshotURL = v }
                if let v = newLine.publicIDRight { existing.publicIDRight = v }
                if let v = newLine.line { existing.line = v }
                if let v = newLine.isSelected { existing.isSelected = v }

                drivers[driver] = existing
            } else {
                drivers[driver] = newLine
            }
        }
    }
}
