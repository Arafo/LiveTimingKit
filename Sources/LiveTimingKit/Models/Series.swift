import Foundation

public struct Series: Codable, Sendable {
    public let utc: String
    public let lap: Int?
    public let qualifyingPart: Int?

    enum CodingKeys: String, CodingKey {
        case utc = "Utc"
        case lap = "Lap"
        case qualifyingPart = "QualifyingPart"
    }

    public init(utc: String, lap: Int? = nil, qualifyingPart: Int? = nil) {
        self.utc = utc
        self.lap = lap
        self.qualifyingPart = qualifyingPart
    }
}
