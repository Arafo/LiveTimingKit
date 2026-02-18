import Foundation

public enum Compound: String, Codable, Sendable {
    case hard = "HARD"
    case medium = "MEDIUM"
    case soft = "SOFT"
    case intermediate = "INTERMEDIATE"
    case wet = "WET"
    case unknown = "UNKNOWN"
    case testUnknown = "TEST_UNKNOWN"
}
