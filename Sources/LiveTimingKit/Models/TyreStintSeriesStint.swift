import Foundation

public struct TyreStintSeriesStint: Codable, Sendable {
    public var compound: Compound?
    public var new: String?
    public var tyresNotChanged: String?
    public var totalLaps: Int?
    public var startLaps: Int?

    enum CodingKeys: String, CodingKey {
        case compound = "Compound"
        case new = "New"
        case tyresNotChanged = "TyresNotChanged"
        case totalLaps = "TotalLaps"
        case startLaps = "StartLaps"
    }

    public init(
        compound: Compound? = nil,
        new: String? = nil,
        tyresNotChanged: String? = nil,
        totalLaps: Int? = nil,
        startLaps: Int? = nil
    ) {
        self.compound = compound
        self.new = new
        self.tyresNotChanged = tyresNotChanged
        self.totalLaps = totalLaps
        self.startLaps = startLaps
    }

    /// Merges non-nil fields from `delta` into `self`, preserving existing values
    /// when the incoming delta omits them.
    public mutating func merge(with delta: TyreStintSeriesStint) {
        if let v = delta.compound { compound = v }
        if let v = delta.new { new = v }
        if let v = delta.tyresNotChanged { tyresNotChanged = v }
        if let v = delta.totalLaps { totalLaps = v }
        if let v = delta.startLaps { startLaps = v }
    }
}
