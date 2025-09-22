import Foundation

public actor ReplayClient: Sendable {
    private let events: [RawEvent]
    private let processor: EventProcessor
    private let speed: Double

    private var currentIndex: Int = 0
    private var isRunning = false
    private var isPaused = false
    private var lastTimestamp: Date?
    private var seekVersion: UInt64 = 0

    public var loop: Bool = false

    public init(file: URL, speed: Double = 1.0, processor: EventProcessor) throws {
        let data = try Data(contentsOf: file)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedEvents = try decoder.decode([RawEvent].self, from: data)
        self.events = decodedEvents.sorted { $0.timestamp < $1.timestamp }
        self.processor = processor
        self.speed = speed
    }

    init(events: [RawEvent], speed: Double = 1.0, processor: EventProcessor) {
        self.events = events.sorted { $0.timestamp < $1.timestamp }
        self.processor = processor
        self.speed = speed
    }

    public func start() async throws {
        guard !isRunning else { return }
        guard !events.isEmpty else { return }

        isRunning = true
        defer { isRunning = false }

        if currentIndex >= events.count {
            currentIndex = 0
            lastTimestamp = nil
        }

        while !Task.isCancelled {
            if currentIndex >= events.count {
                if loop {
                    currentIndex = 0
                    lastTimestamp = nil
                    continue
                } else {
                    break
                }
            }

            let eventIndex = currentIndex
            let event = events[eventIndex]
            currentIndex += 1
            let eventVersion = seekVersion

            let delay = computeDelay(for: event)
            try await waitForDelay(delay, version: eventVersion)
            guard eventVersion == seekVersion else { continue }

            do {
                try await processor.process(event)
            } catch {
                // Skip events that fail to process during replay
            }

            lastTimestamp = event.timestamp
        }
    }

    public func pause() {
        isPaused = true
    }

    public func resume() {
        isPaused = false
    }

    public func seek(to date: Date) {
        if let index = events.firstIndex(where: { $0.timestamp >= date }) {
            currentIndex = index
            lastTimestamp = index > 0 ? events[index - 1].timestamp : nil
        } else {
            currentIndex = events.count
            lastTimestamp = events.last?.timestamp
        }
        seekVersion &+= 1
    }

    public func setLoop(_ isEnabled: Bool) {
        loop = isEnabled
    }

    private func computeDelay(for event: RawEvent) -> TimeInterval {
        guard let previous = lastTimestamp else { return 0 }
        let interval = event.timestamp.timeIntervalSince(previous)
        guard interval > 0 else { return 0 }
        let effectiveSpeed = speed > 0 ? speed : 1.0
        return interval / effectiveSpeed
    }

    private func waitForDelay(_ delay: TimeInterval, version: UInt64) async throws {
        guard delay > 0 else {
            try await waitWhilePaused(version: version)
            return
        }

        var remaining = delay
        while remaining > 0 {
            try Task.checkCancellation()
            if version != seekVersion { return }

            let chunk = min(remaining, 0.25)
            try await Task.sleep(nanoseconds: UInt64(chunk * 1_000_000_000))
            remaining -= chunk

            try await waitWhilePaused(version: version)
        }

        try await waitWhilePaused(version: version)
    }

    private func waitWhilePaused(version: UInt64) async throws {
        while isPaused {
            try Task.checkCancellation()
            if version != seekVersion { return }
            try await Task.sleep(nanoseconds: 50_000_000)
        }
    }
}
