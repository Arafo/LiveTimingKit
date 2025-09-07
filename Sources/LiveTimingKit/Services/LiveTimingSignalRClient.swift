import Foundation
import SignalRClient

public actor LiveTimingSignalRClient: LiveTimingService {
    private let connection: HubConnection
    private var continuation: AsyncStream<LiveTimingState>.Continuation?
    public let eventProcessor: LiveTimingEventProcessor

    public init(
        url: String = "https://livetiming.formula1.com/signalrcore"
    ) {
        self.connection = HubConnectionBuilder()
            .withUrl(url: url, transport: .webSockets)
            .withAutomaticReconnect(retryDelays: [0, 2, 10, 30])
            .withHubProtocol(hubProtocol: .json)
            .withLogLevel(logLevel: .information)
            .withServerTimeout(serverTimeout: 30)
            .build()
        self.eventProcessor = LiveTimingDefaultEventProcessor()
    }
    
    public func stream() async -> AsyncStream<LiveTimingState> {
        AsyncStream { continuation in
            self.continuation = continuation
            Task { [connection] in
                await connection.on("feed") { @Sendable (id: String, data: AnyCodable/*[String: AnyCodable]*/, time: String) in
                    
                    try? await self.eventProcessor.process(
                        event: .init(topic: id, payload: data, timestamp: .now)
                    )
                        
                    await continuation.yield(self.eventProcessor.state)
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
                    
                    // TO RECOVER
                    //apply(.fullSnapshot(fullSnapshot))
                    try? await self.eventProcessor.process(
                        snapshot: fullSnapshot
                    )
                } catch {
                    continuation.finish()
                }
            }
        }
    }
}
