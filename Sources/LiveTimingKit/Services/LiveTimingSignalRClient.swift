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
        logger: Logger? = nil
    ) {
        self.hubURL = url
        self.connection = HubConnectionBuilder()
            .withUrl(url: url, transport: .webSockets)
            .withAutomaticReconnect(retryDelays: [0, 2, 10, 30])
            .withHubProtocol(hubProtocol: .json)
            .withLogLevel(logLevel: .information)
            .withServerTimeout(serverTimeout: 30)
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
                self.logInfo("Opening SignalR stream.", metadata: [
                    "hub_url": self.hubURL
                ])
                let closeLogger = self.logger

                await connection.on("feed") { @Sendable (id: String, data: AnyCodable/*[String: AnyCodable]*/, time: String) in
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
                    self.logInfo("Starting SignalR connection.")
                    try await connection.start()
                    self.logInfo("SignalR connection started.")

                    let topics = Topic.allCases.compactMap { $0.rawValue }
                    self.logInfo(
                        "Subscribing to SignalR topics.",
                        metadata: [
                            "topics_count": "\(topics.count)"
                        ]
                    )
                    let fullSnapshot: Envelope = try await connection.invoke(
                        method: "Subscribe",
                        arguments: topics
                    )
                    self.logInfo("SignalR subscribe snapshot received.")

                    do {
                        try await self.eventProcessor.process(snapshot: fullSnapshot)
                        self.logInfo(
                            "SignalR subscribe snapshot parsed.",
                            metadata: [
                                "session_key": fullSnapshot.sessionInfo?.key.map(String.init) ?? "nil",
                                "meeting_key": fullSnapshot.sessionInfo?.meeting?.key.map(String.init) ?? "nil"
                            ]
                        )
                    } catch {
                        self.logError(
                            "Failed to parse SignalR subscribe snapshot.",
                            metadata: [
                                "error": error.localizedDescription
                            ]
                        )
                    }
                } catch {
                    self.logError(
                        "Failed to start/subscribe SignalR connection.",
                        metadata: [
                            "error": error.localizedDescription
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
            logInfo(
                "Received first SignalR feed event.",
                metadata: [
                    "topic": topic,
                    "feed_time": feedTime
                ]
            )
        }

        do {
            try await eventProcessor.process(
                event: .init(topic: topic, payload: payload, timestamp: .now)
            )
            if receivedEventCount <= 3 || receivedEventCount % 50 == 0 {
                logInfo(
                    "Parsed SignalR feed event.",
                    metadata: [
                        "topic": topic,
                        "feed_time": feedTime,
                        "received_events": "\(receivedEventCount)"
                    ]
                )
            }
        } catch {
            parseErrorCount += 1
            logError(
                "Failed to parse SignalR feed event.",
                metadata: [
                    "topic": topic,
                    "feed_time": feedTime,
                    "error": error.localizedDescription,
                    "payload_summary": payloadSummary(payload),
                    "received_events": "\(receivedEventCount)",
                    "parse_errors": "\(parseErrorCount)"
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

    private func logDebug(_ message: String, metadata: [String: String] = [:]) {
        logger.debug(.init(stringLiteral: message), metadata: toLoggerMetadata(metadata))
    }

    private func logInfo(_ message: String, metadata: [String: String] = [:]) {
        logger.info(.init(stringLiteral: message), metadata: toLoggerMetadata(metadata))
    }

    private func logWarning(_ message: String, metadata: [String: String] = [:]) {
        logger.warning(.init(stringLiteral: message), metadata: toLoggerMetadata(metadata))
    }

    private func logError(_ message: String, metadata: [String: String] = [:]) {
        logger.error(.init(stringLiteral: message), metadata: toLoggerMetadata(metadata))
    }

    private func toLoggerMetadata(_ metadata: [String: String]) -> Logger.Metadata {
        var output: Logger.Metadata = [:]
        for (key, value) in metadata {
            output[key] = .string(value)
        }
        return output
    }
}
