import XCTest
@testable import LiveTimingKit

final class EventProcessingTests: XCTestCase {
    func testDefaultEventProcessorPublishesDecodedPayload() async throws {
        let bus = EventBus()
        let registry = DecoderRegistry()
        registry.register(Heartbeat.self, for: .heartbeat)
        let processor = DefaultEventProcessor(bus: bus, registry: registry)

        let expectation = expectation(description: "Heartbeat published")

        let token = await bus.subscribe(to: .heartbeat, as: Heartbeat.self) { payload in
            XCTAssertEqual(payload.utc, Heartbeat.empty.utc)
            expectation.fulfill()
        }

        let payload = try JSONEncoder().encode(Heartbeat.empty)
        let raw = RawEvent(topic: Topic.heartbeat.rawValue, payload: payload, timestamp: Date())

        try await processor.process(raw)

        await fulfillment(of: [expectation], timeout: 1.0)
        await bus.unsubscribe(token)
    }

    func testReplayClientPauseAndResume() async throws {
        let now = Date()
        let events: [RawEvent] = [
            .init(topic: "A", payload: Data(), timestamp: now),
            .init(topic: "B", payload: Data(), timestamp: now.addingTimeInterval(0.5))
        ]

        let processor = CollectingProcessor()
        let client = ReplayClient(events: events, speed: 1.0, processor: processor)

        let playback = Task {
            try await client.start()
        }

        try await Task.sleep(nanoseconds: 50_000_000)
        await client.pause()
        try await Task.sleep(nanoseconds: 200_000_000)

        var processed = await processor.events()
        XCTAssertEqual(processed.count, 1)

        await client.resume()
        try await Task.sleep(nanoseconds: 600_000_000)

        processed = await processor.events()
        XCTAssertEqual(processed.count, 2)

        await playback.value
    }

    func testReplayClientSeekSkipsIntermediateEvents() async throws {
        let now = Date()
        let events: [RawEvent] = [
            .init(topic: "A", payload: Data(), timestamp: now),
            .init(topic: "B", payload: Data(), timestamp: now.addingTimeInterval(0.2)),
            .init(topic: "C", payload: Data(), timestamp: now.addingTimeInterval(0.4))
        ]

        let processor = CollectingProcessor()
        let client = ReplayClient(events: events, speed: 1.0, processor: processor)

        let playback = Task {
            try await client.start()
        }

        try await Task.sleep(nanoseconds: 50_000_000)
        await client.pause()

        var processed = await processor.events()
        XCTAssertEqual(processed.count, 1)

        await client.seek(to: now.addingTimeInterval(0.4))
        await client.resume()
        try await Task.sleep(nanoseconds: 600_000_000)

        processed = await processor.events()
        XCTAssertEqual(processed.count, 2)
        XCTAssertEqual(processed.map { $0.topic }, ["A", "C"])

        await playback.value
    }

    func testLiveTimingFacadeMockMode() async throws {
        let bus = EventBus()
        let registry = DecoderRegistry()
        registry.register(Heartbeat.self, for: .heartbeat)
        let processor = DefaultEventProcessor(bus: bus, registry: registry)

        let expectation = expectation(description: "Mock heartbeat published")
        let token = await bus.subscribe(to: .heartbeat, as: Heartbeat.self) { _ in
            expectation.fulfill()
        }

        let payload = try JSONEncoder().encode(Heartbeat.empty)
        let event = RawEvent(topic: Topic.heartbeat.rawValue, payload: payload, timestamp: Date())
        let liveTiming = try LiveTiming(mode: .mock([event]), bus: bus, processor: processor)

        try await liveTiming.start()

        await fulfillment(of: [expectation], timeout: 1.0)
        await bus.unsubscribe(token)
    }
}

private actor CollectingProcessor: EventProcessor {
    private var stored: [RawEvent] = []

    func process(_ event: RawEvent) async throws {
        stored.append(event)
    }

    func events() -> [RawEvent] {
        stored
    }
}
