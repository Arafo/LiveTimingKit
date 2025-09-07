import Foundation

protocol LiveTimingEventProcessor {
    func process(event: RawEvent) async throws
}

struct RawEvent {
    public let topic: String
    public let payload: [String: AnyCodable]
    public let timestamp: Date
}

final class LiveTimingDefaultEventProcessor: LiveTimingEventProcessor {
    private var state = LiveTimingState()
    private let continuation: AsyncStream<LiveTimingState>.Continuation

    init(
        continuation: AsyncStream<LiveTimingState>.Continuation
    ) {
        self.continuation = continuation
    }

    func process(event: RawEvent) async throws {
        switch Topic(rawValue: event.topic) {
        case .timingData:
            if let timingData = try? event.payload.to(TimingData.self) {
                self.apply(.timingData(timingData))
            }

        case .heartbeat:
             let heartbeat = try! event.payload.to(Heartbeat.self)
                self.apply(.heartbeat(heartbeat))
            
            
        case .timingAppData:
             let timingAppData = try! event.payload.to(TimingAppData.self)
                self.apply(.timingAppData(timingAppData))
            
        default:
            print("*** Topic Id not parsed: \(event.topic)")
            break
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

        case .timingData(let delta):
            state.timingData.merge(with: delta)
            
        case .timingAppData(let delta):
            state.timingAppData.merge(with: delta)

        case .carData(let delta):
            state.carData.merge(with: delta)

        case .position(let delta):
            state.positions.merge(with: delta)

        case .weather(let delta):
            state.weatherData.merge(with: delta)

        case .raw:
            break
        }

        continuation.yield(state)
    }
}
