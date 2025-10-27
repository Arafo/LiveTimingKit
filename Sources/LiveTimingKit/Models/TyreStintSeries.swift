import Foundation

public struct TyreStintSeries: Codable, Sendable {
    public var stints: [String: [TyreStintSeriesStint]]

    enum CodingKeys: String, CodingKey {
        case stints = "Stints"
    }
}

extension TyreStintSeries {
    public mutating func merge(with delta: TyreStintSeries) {
        for (driver, newStints) in delta.stints {
            if stints[driver] == nil {
                stints[driver] = newStints
            } else {
                stints[driver]?.append(contentsOf: newStints)
            }
        }
    }
}
