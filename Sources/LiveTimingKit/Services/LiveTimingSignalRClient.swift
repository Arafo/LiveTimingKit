import Foundation
import SignalRClient

public actor LiveTimingSignalRClient: Sendable {
    private let connection: HubConnection
    private let encoder = JSONEncoder()
    private var state = LiveTimingState()
    private var continuation: AsyncStream<LiveTimingState>.Continuation?
    public private(set) var lastSnapshotData: Data?

    public init(
        url: String = "https://livetiming.formula1.com/signalrcore"
    ) {
        self.connection = HubConnectionBuilder()
            .withUrl(url: url, transport: .webSockets)
            .withAutomaticReconnect(retryDelays: [0, 2, 10, 30])
            .withHubProtocol(hubProtocol: .json)
            .withLogLevel(logLevel: .debug)
            .withServerTimeout(serverTimeout: 30)
            .build()
    }
    
    public func stream() async -> AsyncStream<LiveTimingState> {
        AsyncStream { continuation in
            self.continuation = continuation
            Task { [connection] in
                await connection.on("feed") { @Sendable (id: String, data: [String: AnyCodable], time: String) in
                    switch Topic(rawValue: id) {
                    case .timingData:
                        if let timingData = try? data.to(TimingData.self) {
                            await self.apply(.timingData(timingData))
                        }

                    case .heartbeat:
                        if let heartbeat = try? data.to(Heartbeat.self) {
                            await self.apply(.heartbeat(heartbeat))
                        }

                    default:
                        break
                    }
                }

                await connection.onClosed { error in
                    if let error {
                        continuation.finish()
                    } else {
                        continuation.finish()
                    }
                }
                
                do {
                    try await connection.start()
                    let fullSnapshot: Envelope = try await connection.invoke(
                        method: "Subscribe",
                        arguments: Topic.allCases.compactMap { $0.rawValue }
                    )
                    
                    apply(.fullSnapshot(fullSnapshot))
                } catch {
                    continuation.finish()
                }
            }
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

        case .carData(let delta):
            state.carData.merge(with: delta)

        case .position(let delta):
            state.positions.merge(with: delta)

        case .weather(let delta):
            state.weatherData.merge(with: delta)

        case .raw:
            break
        }

        continuation?.yield(state)
        if let data = try? encoder.encode(state) {
            lastSnapshotData = data
        }
    }
}
