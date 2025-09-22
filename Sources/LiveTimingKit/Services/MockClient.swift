import Foundation

public actor MockClient: Sendable {
    private let events: [RawEvent]
    private let processor: EventProcessor

    public init(events: [RawEvent], processor: EventProcessor) {
        self.events = events
        self.processor = processor
    }

    public func start() async throws {
        for event in events {
            try await processor.process(event)
        }
    }
}
