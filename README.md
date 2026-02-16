# LiveTimingKit

`LiveTimingKit` is a Swift package for consuming Formula 1 live timing data and maintaining a merged in-memory race state.

## Requirements

- iOS 16+
- macOS 13+
- Swift 6.0+

## Installation

Add the package in `Package.swift`:

```swift
.package(url: "https://github.com/Arafo/LiveTimingKit.git", branch: "main")
```

Then add `LiveTimingKit` to your target dependencies.

## Quick Start

```swift
import LiveTimingKit

let client = LiveTimingSignalRClient()
let stream = await client.stream()

for await state in stream {
    // state is continuously merged with incoming updates
    print(state.heartbeat)
}
```

## Data Flow

1. `LiveTimingSignalRClient` connects to the SignalR endpoint.
2. A full snapshot is fetched via `Subscribe`.
3. Incremental topic events are decoded and merged by `LiveTimingDefaultEventProcessor`.
4. Consumers receive `LiveTimingState` updates through `AsyncStream`.

## Supported Topics

The package currently handles topics defined in `Topic` (`Heartbeat`, `TimingData`, `DriverList`, `WeatherData`, `RaceControlMessages`, `CarData`, `Position.z`, and others).

## Development

```bash
swift build
swift test
```
