import Foundation

public struct TyreStintSeries: Codable, Sendable {
    public var stints: [String: [String: TyreStintSeriesStint]]

    public init(stints: [String: [String: TyreStintSeriesStint]] = [:]) {
        self.stints = stints
    }

    enum CodingKeys: String, CodingKey {
        case stints = "Stints"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let dict = try? container.decode([String: [String: TyreStintSeriesStint]].self, forKey: .stints) {
            stints = dict
        } else if let dict = try? container.decode([String: [TyreStintSeriesStint]].self, forKey: .stints) {
            stints = dict.reduce(into: [:]) { result, pair in
                result[pair.key] = Dictionary(
                    uniqueKeysWithValues: pair.value.enumerated().map { (String($0.offset), $0.element) }
                )
            }
        } else {
            stints = [:]
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stints, forKey: .stints)
    }
}

public extension TyreStintSeries {
    mutating func merge(with delta: TyreStintSeries) {
        for (driver, deltaStints) in delta.stints {
            if stints[driver] == nil {
                stints[driver] = deltaStints
                continue
            }

            for (index, deltaStint) in deltaStints {
                if stints[driver]?[index] != nil {
                    stints[driver]?[index]?.merge(with: deltaStint)
                } else {
                    stints[driver]?[index] = deltaStint
                }
            }
        }
    }
}
