import Foundation

public struct ChampionshipPrediction: Codable, Sendable {
    public var drivers: [String: Driver] = [:]
    public var teams: [String: Team] = [:]

    public init(drivers: [String: Driver] = [:], teams: [String: Team] = [:]) {
        self.drivers = drivers
        self.teams = teams
    }

    enum CodingKeys: String, CodingKey {
        case drivers = "Drivers"
        case teams = "Teams"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        drivers = try container.decodeIfPresent([String: Driver].self, forKey: .drivers) ?? [:]
        teams = try container.decodeIfPresent([String: Team].self, forKey: .teams) ?? [:]
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(drivers, forKey: .drivers)
        try container.encode(teams, forKey: .teams)
    }
}

public extension ChampionshipPrediction {
    struct Driver: Codable, Sendable {
        public var racingNumber: String?
        public var currentPosition: Int?
        public var predictedPosition: Int?
        public var currentPoints: Double?
        public var predictedPoints: Double?

        public init(
            racingNumber: String? = nil,
            currentPosition: Int? = nil,
            predictedPosition: Int? = nil,
            currentPoints: Double? = nil,
            predictedPoints: Double? = nil
        ) {
            self.racingNumber = racingNumber
            self.currentPosition = currentPosition
            self.predictedPosition = predictedPosition
            self.currentPoints = currentPoints
            self.predictedPoints = predictedPoints
        }

        enum CodingKeys: String, CodingKey {
            case racingNumber = "RacingNumber"
            case currentPosition = "CurrentPosition"
            case predictedPosition = "PredictedPosition"
            case currentPoints = "CurrentPoints"
            case predictedPoints = "PredictedPoints"
        }
    }

    struct Team: Codable, Sendable {
        public var teamName: String?
        public var currentPosition: Int?
        public var predictedPosition: Int?
        public var currentPoints: Double?
        public var predictedPoints: Double?

        public init(
            teamName: String? = nil,
            currentPosition: Int? = nil,
            predictedPosition: Int? = nil,
            currentPoints: Double? = nil,
            predictedPoints: Double? = nil
        ) {
            self.teamName = teamName
            self.currentPosition = currentPosition
            self.predictedPosition = predictedPosition
            self.currentPoints = currentPoints
            self.predictedPoints = predictedPoints
        }

        enum CodingKeys: String, CodingKey {
            case teamName = "TeamName"
            case currentPosition = "CurrentPosition"
            case predictedPosition = "PredictedPosition"
            case currentPoints = "CurrentPoints"
            case predictedPoints = "PredictedPoints"
        }
    }
}

public extension ChampionshipPrediction {
    mutating func merge(with delta: ChampionshipPrediction) {
        for (key, value) in delta.drivers {
            if var existing = drivers[key] {
                if let v = value.racingNumber { existing.racingNumber = v }
                if let v = value.currentPosition { existing.currentPosition = v }
                if let v = value.predictedPosition { existing.predictedPosition = v }
                if let v = value.currentPoints { existing.currentPoints = v }
                if let v = value.predictedPoints { existing.predictedPoints = v }
                drivers[key] = existing
            } else {
                drivers[key] = value
            }
        }

        for (key, value) in delta.teams {
            if var existing = teams[key] {
                if let v = value.teamName { existing.teamName = v }
                if let v = value.currentPosition { existing.currentPosition = v }
                if let v = value.predictedPosition { existing.predictedPosition = v }
                if let v = value.currentPoints { existing.currentPoints = v }
                if let v = value.predictedPoints { existing.predictedPoints = v }
                teams[key] = existing
            } else {
                teams[key] = value
            }
        }
    }
}
