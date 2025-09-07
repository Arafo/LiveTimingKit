import Foundation

public struct TyreStintSeries: Codable, Sendable {
    public var stints: [String: [TyreStintSeriesStint]]

    enum CodingKeys: String, CodingKey {
        case stints = "Stints"
    }

    public init(stints: [String: [TyreStintSeriesStint]] = [:]) {
        self.stints = stints
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let arrayStints = try? container.decode([String: [TyreStintSeriesStint]].self, forKey: .stints) {
            stints = arrayStints
            return
        }

        if let keyedStints = try? container.decode([String: [String: TyreStintSeriesStint]].self, forKey: .stints) {
            stints = Self.normalize(keyedStints)
            return
        }

        stints = [:]
    }

    private static func normalize(
        _ keyedStints: [String: [String: TyreStintSeriesStint]]
    ) -> [String: [TyreStintSeriesStint]] {
        keyedStints.reduce(into: [:]) { result, item in
            result[item.key] = item.value
                .sorted { lhs, rhs in
                    let lhsIndex = Int(lhs.key) ?? Int.min
                    let rhsIndex = Int(rhs.key) ?? Int.min
                    if lhsIndex == rhsIndex {
                        return lhs.key < rhs.key
                    }
                    return lhsIndex < rhsIndex
                }
                .map(\.value)
        }
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
