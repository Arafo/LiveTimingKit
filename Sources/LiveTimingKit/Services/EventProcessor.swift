import Foundation
import NIOCore

public protocol LiveTimingEventProcessor: Actor {
    var state: LiveTimingState { get async }
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
    
    //private var state = LiveTimingState()
    //private let continuation: AsyncStream<LiveTimingState>.Continuation

    public init(
        //continuation: AsyncStream<LiveTimingState>.Continuation
    ) {
        //self.continuation = continuation
    }
    
    public func process(snapshot: Envelope) async throws {
        //if let carData = snapshot.carData { state.carData = carData }
        //if let positionData = snapshot.positionData { state.positions = positionData }
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
    }

    public func process(event: RawEvent) async throws {
        //print("*** - Parsing event \(event.topic)")
        switch Topic(rawValue: event.topic) {
        case .timingData:
            let timingData = try! event.payload.to(TimingData.self)
            apply(.timingData(timingData))

        case .heartbeat:
            let heartbeat = try! event.payload.to(Heartbeat.self)
            apply(.heartbeat(heartbeat))
            
        case .timingAppData:
            let timingAppData = try! event.payload.to(TimingAppData.self)
            apply(.timingAppData(timingAppData))
            
        case .driverList:
            let driverList = try! event.payload.to(DriverList.self)
            apply(.driverList(driverList))

        case .carData:
            let cardDate = try! event.payload.to(CarData.self)
            apply(.carData(cardDate))
            
        case .carDataZ:
            break
            //print("*** TO BE PARSE: carDataZ")
            
        case .position:
            let positionData = try! event.payload.to(PositionData.self)
            apply(.position(positionData))
            
        case .positionZ:
            //let data = try event.payload.to(String.self)
            //let data = try Data(base64Encoded: event.payload.to(String.self))
            //let decompressedData = try (data as! NSData).decompressed(using: .zlib)
            //let string = String(data: decompressedData as Data, encoding: .utf8)
            //let a = DecompressUtilities.inflateBase64Data(event.payload.values.first!.description)
            let positionZData = try event.payload.to(PositionZ.self)
            apply(.positionZ(positionZData))

        case .weatherData:
            let weatherData = try! event.payload.to(WeatherData.self)
            apply(.weather(weatherData))
            
        case .timingStats:
            let timingStats = try! event.payload.to(TimingStats.self)
            apply(.timingStats(timingStats))
            
        case .lapCount:
            let lapCount = try! event.payload.to(LapCount.self)
            apply(.lapCount(lapCount))
            
        case .sessionInfo:
            let sessionInfo = try! event.payload.to(SessionInfo.self)
            apply(.sessionInfo(sessionInfo))

        default:
            print("*** Topic Id not parsed: \(event.topic)")
        }
    }
    
    private func apply(_ message: LiveTimingMessage) {
        switch message {
        case .fullSnapshot(let snapshot):
            //if let carData = snapshot.carData { state.carData = carData }
            //if let positionData = snapshot.positionData { state.positions = positionData }
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

        case .position(let delta):
            break
            //state.positions.merge(with: delta)
            
        case .positionZ(let delta):
            state.positionZ.merge(with: delta)
            
        case .carDataZ(let delta):
            print("*** carDataZ")
            
        case .weather(let delta):
            state.weatherData.merge(with: delta)
            
        case .timingStats(let delta):
            state.timingStats.merge(with: delta)
            
        case .lapCount(let delta):
            state.lapCount.merge(with: delta)

        case .raw:
            break
        }

        //continuation.yield(state)
    }
}
