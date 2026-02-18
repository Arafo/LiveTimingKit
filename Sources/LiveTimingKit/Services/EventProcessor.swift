import Foundation

public protocol LiveTimingEventProcessor: Actor {
    var state: LiveTimingState { get async }
    func process(snapshot: Envelope) async throws
    func process(event: RawEvent) async throws
}

public struct RawEvent: Sendable {
    public init(
        topic: String,
        payload: AnyCodable,
        timestamp: Date
    ) {
        self.topic = topic
        self.payload = payload
        self.timestamp = timestamp
    }
    
    public let topic: String
    public let payload: AnyCodable
    public let timestamp: Date
}

public actor LiveTimingDefaultEventProcessor: LiveTimingEventProcessor {
    
    public var state: LiveTimingState = .init()
    private var encoder: JSONEncoder = .init()
    private var decoder: JSONDecoder = .init()
    
    //private var state = LiveTimingState()
    //private let continuation: AsyncStream<LiveTimingState>.Continuation

    public init(
        //continuation: AsyncStream<LiveTimingState>.Continuation
    ) {
        //self.continuation = continuation
    }
    
    public func process(snapshot: Envelope) async throws {
        if let carData = snapshot.carData { state.carData = carData }
        if let heartbeat = snapshot.heartbeat { state.heartbeat = heartbeat }
        if let extrapolatedClock = snapshot.extrapolatedClock { state.extrapolatedClock = extrapolatedClock }
        if let topThree = snapshot.topThree { state.topThree = topThree }
        if let timingStats = snapshot.timingStats { state.timingStats = timingStats }
        if let timingAppData = snapshot.timingAppData { state.timingAppData = timingAppData }
        if let weatherData = snapshot.weatherData { state.weatherData = weatherData }
        if let trackStatus = snapshot.trackStatus { state.trackStatus = trackStatus }
        if let driverList = snapshot.driverList { state.driverList = driverList }
        if let raceControlMessages = snapshot.raceControlMessages { state.raceControlMessages = raceControlMessages }
        if let sessionInfo = snapshot.sessionInfo { state.sessionInfo = sessionInfo }
        if let sessionData = snapshot.sessionData { state.sessionData = sessionData }
        if let lapCount = snapshot.lapCount { state.lapCount = lapCount }
        if let timingData = snapshot.timingData { state.timingData = timingData }
        if let teamRadio = snapshot.teamRadio { state.teamRadio = teamRadio }
        if let tyreStintSeries = snapshot.tyreStintSeries { state.tyreStintSeries = tyreStintSeries }
        if let championshipPrediction = snapshot.championshipPrediction { state.championshipPrediction = championshipPrediction }
        if let pitStopSeries = snapshot.pitStopSeries { state.pitStopSeries = pitStopSeries }
        if let pitLaneTimeCollection = snapshot.pitLaneTimeCollection { state.pitLaneTimeCollection = pitLaneTimeCollection }
        if let positionZ = snapshot.positionZ { state.positionZ = positionZ }
    }

    public func process(event: RawEvent) async throws {
        switch Topic(rawValue: event.topic) {
        case .timingData:
            let timingData = try event.payload.to(TimingData.self, encoder: encoder, decoder: decoder)
            apply(.timingData(timingData))

        case .heartbeat:
            let heartbeat = try event.payload.to(Heartbeat.self, encoder: encoder, decoder: decoder)
            apply(.heartbeat(heartbeat))
            
        case .timingAppData:
            let timingAppData = try event.payload.to(TimingAppData.self, encoder: encoder, decoder: decoder)
            apply(.timingAppData(timingAppData))
            
        case .driverList:
            let driverList = try event.payload.to(DriverList.self, encoder: encoder, decoder: decoder)
            apply(.driverList(driverList))

        case .carData:
            let cardDate = try event.payload.to(CarData.self, encoder: encoder, decoder: decoder)
            apply(.carData(cardDate))
            
        case .carDataZ:
            break
            //print("*** TO BE PARSE: carDataZ")
            
        case .position:
            let positionData = try event.payload.to(PositionData.self, encoder: encoder, decoder: decoder)
            apply(.position(positionData))
            
        case .positionZ:
            //let data = try event.payload.to(String.self)
            //let data = try Data(base64Encoded: event.payload.to(String.self))
            //let decompressedData = try (data as! NSData).decompressed(using: .zlib)
            //let string = String(data: decompressedData as Data, encoding: .utf8)
            //let a = DecompressUtilities.inflateBase64Data(event.payload.values.first!.description)
            let positionZData = try event.payload.to(PositionZ.self, encoder: encoder, decoder: decoder)
            apply(.positionZ(positionZData))

        case .weatherData:
            let weatherData = try event.payload.to(WeatherData.self, encoder: encoder, decoder: decoder)
            apply(.weather(weatherData))
            
        case .timingStats:
            let timingStats = try event.payload.to(TimingStats.self, encoder: encoder, decoder: decoder)
            apply(.timingStats(timingStats))
            
        case .lapCount:
            let lapCount = try event.payload.to(LapCount.self, encoder: encoder, decoder: decoder)
            apply(.lapCount(lapCount))
            
        case .sessionInfo:
            let sessionInfo = try event.payload.to(SessionInfo.self, encoder: encoder, decoder: decoder)
            apply(.sessionInfo(sessionInfo))

        case .raceControlMessages:
            let messages = try event.payload.to(RaceControlMessages.self, encoder: encoder, decoder: decoder)
            apply(.raceControlMessages(messages))

        case .teamRadio:
            let teamRadio = try event.payload.to(TeamRadio.self, encoder: encoder, decoder: decoder)
            apply(.teamRadio(teamRadio))

        case .tyreStintSeries:
            let series = try event.payload.to(TyreStintSeries.self, encoder: encoder, decoder: decoder)
            apply(.tyreStintSeries(series))

        case .trackStatus:
            let status = try event.payload.to(TrackStatus.self, encoder: encoder, decoder: decoder)
            apply(.trackStatus(status))

        case .topThree:
            let topThree = try event.payload.to(TopThree.self, encoder: encoder, decoder: decoder)
            apply(.topThree(topThree))

        case .sessionData:
            let sessionData = try event.payload.to(SessionData.self, encoder: encoder, decoder: decoder)
            apply(.sessionData(sessionData))

        case .extrapolatedClock:
            let clock = try event.payload.to(ExtrapolatedClock.self, encoder: encoder, decoder: decoder)
            apply(.extrapolatedClock(clock))

        case .championshipPrediction:
            let prediction = try event.payload.to(ChampionshipPrediction.self, encoder: encoder, decoder: decoder)
            apply(.championshipPrediction(prediction))

        case .pitStopSeries:
            let series = try event.payload.to(PitStopSeries.self, encoder: encoder, decoder: decoder)
            apply(.pitStopSeries(series))

        case .pitLaneTimeCollection:
            let collection = try event.payload.to(PitLaneTimeCollection.self, encoder: encoder, decoder: decoder)
            apply(.pitLaneTimeCollection(collection))

        default:
            print("*** Topic Id not parsed: \(event.topic)")
        }
    }
    
    private func apply(_ message: LiveTimingMessage) {
        switch message {
        case .fullSnapshot(let snapshot):
            if let carData = snapshot.carData { state.carData = carData }
            if let heartbeat = snapshot.heartbeat { state.heartbeat = heartbeat }
            if let extrapolatedClock = snapshot.extrapolatedClock { state.extrapolatedClock = extrapolatedClock }
            if let topThree = snapshot.topThree { state.topThree = topThree }
            if let timingStats = snapshot.timingStats { state.timingStats = timingStats }
            if let timingAppData = snapshot.timingAppData { state.timingAppData = timingAppData }
            if let weatherData = snapshot.weatherData { state.weatherData = weatherData }
            if let trackStatus = snapshot.trackStatus { state.trackStatus = trackStatus }
            if let driverList = snapshot.driverList { state.driverList = driverList }
            if let raceControlMessages = snapshot.raceControlMessages { state.raceControlMessages = raceControlMessages }
            if let sessionInfo = snapshot.sessionInfo { state.sessionInfo = sessionInfo }
            if let sessionData = snapshot.sessionData { state.sessionData = sessionData }
            if let lapCount = snapshot.lapCount { state.lapCount = lapCount }
            if let timingData = snapshot.timingData { state.timingData = timingData }
            if let teamRadio = snapshot.teamRadio { state.teamRadio = teamRadio }
            if let tyreStintSeries = snapshot.tyreStintSeries { state.tyreStintSeries = tyreStintSeries }
            if let championshipPrediction = snapshot.championshipPrediction { state.championshipPrediction = championshipPrediction }
            if let pitStopSeries = snapshot.pitStopSeries { state.pitStopSeries = pitStopSeries }
            if let pitLaneTimeCollection = snapshot.pitLaneTimeCollection { state.pitLaneTimeCollection = pitLaneTimeCollection }
            if let positionZ = snapshot.positionZ { state.positionZ = positionZ }

        case .heartbeat(let hb):
            state.heartbeat = hb
            
        case .sessionInfo(let delta):
            state.sessionInfo = delta

        case .timingData(let delta):
            state.timingData.merge(with: delta)
            
        case .timingAppData(let delta):
            state.timingAppData.merge(with: delta)
            
        case .driverList(let delta):
            state.driverList.merge(with: delta)

        case .carData(let delta):
            state.carData.merge(with: delta)

        case .position:
            break
            //state.positions.merge(with: delta)
            
        case .positionZ(let delta):
            state.positionZ.merge(with: delta)
            
        case .carDataZ:
            print("*** carDataZ")
            
        case .weather(let delta):
            state.weatherData.merge(with: delta)
            
        case .timingStats(let delta):
            state.timingStats.merge(with: delta)
            
        case .lapCount(let delta):
            state.lapCount.merge(with: delta)

        case .raceControlMessages(let delta):
            if var existing = state.raceControlMessages {
                existing.merge(with: delta)
                state.raceControlMessages = existing
            } else {
                state.raceControlMessages = delta
            }

        case .teamRadio(let delta):
            if var existing = state.teamRadio {
                existing.merge(with: delta)
                state.teamRadio = existing
            } else {
                state.teamRadio = delta
            }

        case .tyreStintSeries(let delta):
            if var existing = state.tyreStintSeries {
                existing.merge(with: delta)
                state.tyreStintSeries = existing
            } else {
                state.tyreStintSeries = delta
            }

        case .trackStatus(let delta):
            state.trackStatus = delta

        case .topThree(let delta):
            state.topThree = delta

        case .sessionData(let delta):
            state.sessionData = delta

        case .extrapolatedClock(let delta):
            state.extrapolatedClock = .init(remaining: delta.remaining, extrapolating: delta.extrapolating)

        case .championshipPrediction(let delta):
            if var existing = state.championshipPrediction {
                existing.merge(with: delta)
                state.championshipPrediction = existing
            } else {
                state.championshipPrediction = delta
            }

        case .pitStopSeries(let delta):
            if var existing = state.pitStopSeries {
                existing.merge(with: delta)
                state.pitStopSeries = existing
            } else {
                state.pitStopSeries = delta
            }

        case .pitLaneTimeCollection(let delta):
            if var existing = state.pitLaneTimeCollection {
                existing.merge(with: delta)
                state.pitLaneTimeCollection = existing
            } else {
                state.pitLaneTimeCollection = delta
            }

        case .raw:
            break
        }

        //continuation.yield(state)
    }
}
