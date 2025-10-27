import Foundation

public struct TeamRadio: Codable, Sendable {
    public var captures: [String: Capture]

    public init(captures: [String: Capture]) {
        self.captures = captures
    }

    enum CodingKeys: String, CodingKey {
        case captures = "Captures"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let dict = try? container.decode([String: Capture].self, forKey: .captures) {
            captures = dict
        } else if let array = try? container.decode([Capture].self, forKey: .captures) {
            captures = Dictionary(
                uniqueKeysWithValues: array.enumerated().map { (String($0.offset), $0.element) }
            )
        } else {
            captures = [:]
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(captures, forKey: .captures)
    }
}

public extension TeamRadio {
    struct Capture: Codable, Sendable {
        public var utc: String?
        public var racingNumber: String?
        public var path: String?
        public var downloadedFilePath: String?
        public var transcription: String?

        public init(
            utc: String? = nil,
            racingNumber: String? = nil,
            path: String? = nil,
            downloadedFilePath: String? = nil,
            transcription: String? = nil
        ) {
            self.utc = utc
            self.racingNumber = racingNumber
            self.path = path
            self.downloadedFilePath = downloadedFilePath
            self.transcription = transcription
        }

        enum CodingKeys: String, CodingKey {
            case utc = "Utc"
            case racingNumber = "RacingNumber"
            case path = "Path"
            case downloadedFilePath = "DownloadedFilePath"
            case transcription = "Transcription"
        }
    }
}

public extension TeamRadio {
    mutating func merge(with delta: TeamRadio) {
        for (key, value) in delta.captures {
            captures[key] = value
        }
    }
}
