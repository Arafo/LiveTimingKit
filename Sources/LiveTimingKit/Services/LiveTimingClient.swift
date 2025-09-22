import Foundation
import SignalRClient

public actor LiveTimingClient: Sendable {
    private let connection: HubConnection
    private let processor: EventProcessor
    private let encoder = JSONEncoder()
    private let isoFormatter: ISO8601DateFormatter

    public init(url: URL, bus: EventBus, processor: EventProcessor) {
        self.connection = HubConnectionBuilder()
            .withUrl(url: url.absoluteString, transport: .webSockets)
            .withAutomaticReconnect(retryDelays: [0, 2, 10, 30])
            .withHubProtocol(hubProtocol: .json)
            .withLogLevel(logLevel: .info)
            .withServerTimeout(serverTimeout: 30)
            .build()
        self.processor = processor
        self.isoFormatter = ISO8601DateFormatter()
        self.isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.encoder.dateEncodingStrategy = .iso8601
        _ = bus
    }

    public func start() async throws {
        await configureHandlers()

        do {
            try await connection.start()
            let snapshot: Envelope = try await connection.invoke(
                method: "Subscribe",
                arguments: Topic.allCases.map { $0.rawValue }
            )
            await processInitialSnapshot(snapshot)
        } catch {
            throw error
        }
    }

    private func configureHandlers() async {
        await connection.on("feed") { [weak self] (topic: String, data: [String: AnyCodable], time: String) in
            guard let self else { return }
            await self.handleFeed(topic: topic, data: data, time: time)
        }
    }

    private func handleFeed(topic: String, data: [String: AnyCodable], time: String) async {
        let timestamp = isoFormatter.date(from: time) ?? Date()
        do {
            let payload = try encodePayload(data)
            let event = RawEvent(topic: topic, payload: payload, timestamp: timestamp)
            try await processor.process(event)
        } catch {
            // Drop events that cannot be encoded or processed
        }
    }

    private func processInitialSnapshot(_ snapshot: Envelope) async {
        let now = Date()
        await publish(snapshot.heartbeat, topic: .heartbeat, timestamp: now)
        await publish(snapshot.extrapolatedClock, topic: .extrapolatedClock, timestamp: now)
        await publish(snapshot.topThree, topic: .topThree, timestamp: now)
        await publish(snapshot.timingStats, topic: .timingStats, timestamp: now)
        await publish(snapshot.timingAppData, topic: .timingAppData, timestamp: now)
        await publish(snapshot.weatherData, topic: .weatherData, timestamp: now)
        await publish(snapshot.trackStatus, topic: .trackStatus, timestamp: now)
        await publish(snapshot.driverList, topic: .driverList, timestamp: now)
        await publish(snapshot.raceControlMessages, topic: .raceControlMessages, timestamp: now)
        await publish(snapshot.sessionInfo, topic: .sessionInfo, timestamp: now)
        await publish(snapshot.sessionData, topic: .sessionData, timestamp: now)
        await publish(snapshot.lapCount, topic: .lapCount, timestamp: now)
        await publish(snapshot.timingData, topic: .timingData, timestamp: now)
        await publish(snapshot.teamRadio, topic: .teamRadio, timestamp: now)
        await publish(snapshot.tyreStintSeries, topic: .tyreStintSeries, timestamp: now)
    }

    private func publish<Value: Encodable>(_ value: Value?, topic: Topic, timestamp: Date) async {
        guard let value else { return }
        do {
            let payload = try encoder.encode(value)
            let event = RawEvent(topic: topic.rawValue, payload: payload, timestamp: timestamp)
            try await processor.process(event)
        } catch {
            // Ignore encoding failures for optional snapshot values
        }
    }

    private func encodePayload(_ dictionary: [String: AnyCodable]) throws -> Data {
        let wrapper = AnyCodableWrapper(dictionary: dictionary)
        return try encoder.encode(wrapper.dictionary)
    }
}
