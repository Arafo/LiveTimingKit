import Foundation

/// Keyed storage: driver number → (stint index → stint data).
/// Using `[Int: TyreStintSeriesStint]` as the per-driver value preserves the
/// original index from the SignalR delta so that subsequent partial updates can
/// update the correct stint in-place instead of appending duplicates.
public struct TyreStintSeries: Codable, Sendable {
    public var stints: [String: [Int: TyreStintSeriesStint]]

    enum CodingKeys: String, CodingKey {
        case stints = "Stints"
    }

    public init(stints: [String: [Int: TyreStintSeriesStint]] = [:]) {
        self.stints = stints
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Full snapshot arrives as [driver: [TyreStintSeriesStint]] — synthesise
        // sequential indices 0, 1, 2 … for each driver's array.
        if let arrayStints = try? container.decode([String: [TyreStintSeriesStint]].self, forKey: .stints) {
            stints = Self.indexFromArray(arrayStints)
            return
        }

        // Delta arrives as [driver: [stintIndex: TyreStintSeriesStint]] — keep
        // the original string-key indices, converting them to Int.
        if let keyedStints = try? container.decode([String: [String: TyreStintSeriesStint]].self, forKey: .stints) {
            stints = Self.indexFromKeyed(keyedStints)
            return
        }

        stints = [:]
    }

    // MARK: - Private helpers

    /// Convert a plain array (snapshot) into an index-keyed dict.
    private static func indexFromArray(
        _ arrayStints: [String: [TyreStintSeriesStint]]
    ) -> [String: [Int: TyreStintSeriesStint]] {
        arrayStints.reduce(into: [:]) { result, item in
            result[item.key] = Dictionary(
                uniqueKeysWithValues: item.value.enumerated().map { ($0.offset, $0.element) }
            )
        }
    }

    /// Convert a keyed dict (delta) into an index-keyed dict, dropping entries
    /// whose keys cannot be parsed as integers.
    private static func indexFromKeyed(
        _ keyedStints: [String: [String: TyreStintSeriesStint]]
    ) -> [String: [Int: TyreStintSeriesStint]] {
        keyedStints.reduce(into: [:]) { result, item in
            result[item.key] = item.value.reduce(into: [:]) { acc, pair in
                if let idx = Int(pair.key) {
                    acc[idx] = pair.value
                }
            }
        }
    }
}

extension TyreStintSeries {
    public mutating func merge(with delta: TyreStintSeries) {
        for (driver, deltaStints) in delta.stints {
            if stints[driver] == nil {
                // No existing data for this driver — store the delta as-is.
                stints[driver] = deltaStints
            } else {
                // Update or insert each stint at its explicit index so that a
                // partial delta (e.g. only index 1 updated) merges field-by-field
                // rather than appending a duplicate entry.
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
}
