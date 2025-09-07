import Foundation

public struct DriverList: Codable, Sendable {
    public let drivers: [String: Driver]
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
                map[key.stringValue] = try container.decode(Driver.self, forKey: key)
            }
        }
        self.drivers = map
        self.kf = kfValue
    }
}
