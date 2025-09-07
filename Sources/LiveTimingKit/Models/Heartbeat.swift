import Foundation

public struct Heartbeat: Codable, Sendable {
    let utc: String
    let kf: Bool?

    enum CodingKeys: String, CodingKey {
        case utc = "Utc"
        case kf = "_kf"
    }
}

extension Heartbeat {
    public static var empty: Self {
        .init(utc: "", kf: false)
    }
}
