import Foundation

public enum LiveTimingMode {
    case live(URL)
    case replay(URL, speed: Double = 1.0)
    case mock([RawEvent])
}

public final class LiveTiming {
    private let client: any Sendable

    public init(mode: LiveTimingMode, bus: EventBus, processor: EventProcessor) throws {
        switch mode {
        case .live(let url):
            self.client = LiveTimingClient(url: url, bus: bus, processor: processor)
        case .replay(let file, let speed):
            self.client = try ReplayClient(file: file, speed: speed, processor: processor)
        case .mock(let events):
            self.client = MockClient(events: events, processor: processor)
        }
    }

    public func start() async throws {
        if let live = client as? LiveTimingClient {
            try await live.start()
        } else if let replay = client as? ReplayClient {
            try await replay.start()
        } else if let mock = client as? MockClient {
            try await mock.start()
        }
    }

    public func pause() async {
        guard let replay = client as? ReplayClient else { return }
        await replay.pause()
    }

    public func resume() async {
        guard let replay = client as? ReplayClient else { return }
        await replay.resume()
    }

    public func seek(to date: Date) async {
        guard let replay = client as? ReplayClient else { return }
        await replay.seek(to: date)
    }

    public func setLoop(_ isEnabled: Bool) async {
        guard let replay = client as? ReplayClient else { return }
        await replay.setLoop(isEnabled)
    }
}
