import Foundation
import Logging
import SignalRClient

public actor LiveTimingSignalRClient: LiveTimingService {
    private let connection: HubConnection
    private let hubURL: String
    private var continuation: AsyncStream<LiveTimingState>.Continuation?
    public let eventProcessor: LiveTimingEventProcessor
    private let logger: Logger
    private var receivedEventCount = 0
    private var parseErrorCount = 0
    private var firstEventAt: Date?

    public init(
        url: String = "https://livetiming.formula1.com/signalrcore",
        token: String? = nil,
        logger: Logger? = nil
    ) {
        var connectionOptions = HttpConnectionOptions()
        connectionOptions.transport = .webSockets
        if let token, !token.isEmpty {
            connectionOptions.accessTokenFactory = { token }
        }

        self.hubURL = url
        self.connection = HubConnectionBuilder()
            .withUrl(url: url, options: connectionOptions)
            .withAutomaticReconnect(retryDelays: [0, 2, 10, 30])
            .withHubProtocol(hubProtocol: .json)
            .withLogLevel(logLevel: .debug)
            .withServerTimeout(serverTimeout: 3000)
            .build()
        var configuredLogger = logger ?? Logger(label: "laptimes.signalr.client")
        configuredLogger[metadataKey: "component"] = .string("signalr-client")
        self.logger = configuredLogger
        self.eventProcessor = LiveTimingDefaultEventProcessor()
    }
    
    public func stream() async -> AsyncStream<LiveTimingState> {
        AsyncStream { continuation in
            self.continuation = continuation
            Task { [connection] in
                self.logger.info("Opening SignalR stream.", metadata: [
                    "hub_url": .string(self.hubURL)
                ])
                let closeLogger = self.logger

                await connection.on("feed") { @Sendable (id: String, data: AnyCodable, time: String) in
                    await self.handleFeed(
                        topic: id,
                        payload: data,
                        feedTime: time,
                        continuation: continuation
                    )
                }

                await connection.onClosed { error in
                    if let error {
                        closeLogger.error(
                            "SignalR connection closed with error.",
                            metadata: [
                                "error": .string(error.localizedDescription)
                            ]
                        )
                    } else {
                        closeLogger.warning("SignalR connection closed.")
                    }
                    continuation.finish()
                }
                
                do {
                    self.logger.info("Starting SignalR connection.")
                    try await connection.start()
                    self.logger.info("SignalR connection started.")

                    let topics = Topic.allCases.map(\.rawValue)
                    self.logger.info(
                        "Subscribing to SignalR topics.",
                        metadata: [
                            "topics_count": .string("\(topics.count)")
                        ]
                    )
                    let fullSnapshot: Envelope = try await connection.invoke(
                        method: "Subscribe",
                        arguments: topics
                    )
                    self.logger.info("SignalR subscribe snapshot received.")

                    do {
                        try await self.eventProcessor.process(snapshot: fullSnapshot)
                        self.logger.info(
                            "SignalR subscribe snapshot parsed.",
                            metadata: [
                                "session_key": .string(fullSnapshot.sessionInfo?.key.map(String.init) ?? "nil"),
                                "meeting_key": .string(fullSnapshot.sessionInfo?.meeting?.key.map(String.init) ?? "nil")
                            ]
                        )
                        await continuation.yield(self.eventProcessor.state)
                    } catch {
                        self.logger.error(
                            "Failed to parse SignalR subscribe snapshot.",
                            metadata: [
                                "error": .string(error.localizedDescription)
                            ]
                        )
                    }
                } catch {
                    self.logger.error(
                        "Failed to start/subscribe SignalR connection.",
                        metadata: [
                            "error": .string(error.localizedDescription)
                        ]
                    )
                    continuation.finish()
                }
            }
        }
    }

    private func handleFeed(
        topic: String,
        payload: AnyCodable,
        feedTime: String,
        continuation: AsyncStream<LiveTimingState>.Continuation
    ) async {
        receivedEventCount += 1

        if firstEventAt == nil {
            firstEventAt = Date()
            logger.info(
                "Received first SignalR feed event.",
                metadata: [
                    "topic": .string(topic),
                    "feed_time": .string(feedTime)
                ]
            )
        }

        do {
            try await eventProcessor.process(
                event: .init(topic: topic, payload: payload, timestamp: .now)
            )
            if receivedEventCount <= 3 || receivedEventCount % 50 == 0 {
                logger.info(
                    "Parsed SignalR feed event.",
                    metadata: [
                        "topic": .string(topic),
                        "feed_time": .string(feedTime),
                        "received_events": .string("\(receivedEventCount)")
                    ]
                )
            }
        } catch {
            parseErrorCount += 1
            logger.error(
                "Failed to parse SignalR feed event.",
                metadata: [
                    "topic": .string(topic),
                    "feed_time": .string(feedTime),
                    "error": .string(error.localizedDescription),
                    "payload_summary": .string(payloadSummary(payload)),
                    "received_events": .string("\(receivedEventCount)"),
                    "parse_errors": .string("\(parseErrorCount)")
                ]
            )
        }

        await continuation.yield(eventProcessor.state)
    }

    private func payloadSummary(_ payload: AnyCodable) -> String {
        switch payload.value {
        case let dict as [String: Any]:
            let keys = dict.keys.sorted()
            let prefix = keys.prefix(8).joined(separator: ",")
            if keys.count > 8 {
                return "dictionary(keys=\(prefix),total=\(keys.count))"
            }
            return "dictionary(keys=\(prefix))"
        case let array as [Any]:
            return "array(count=\(array.count))"
        case let string as String:
            return "string(length=\(string.count))"
        default:
            return "type=\(String(describing: type(of: payload.value)))"
        }
    }

}
