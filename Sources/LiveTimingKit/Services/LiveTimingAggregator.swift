//import Foundation
//
//public final class LiveTimingAggregator {
//    private var state = LiveTimingState()
//    private var continuation: AsyncStream<LiveTimingState>.Continuation?
//    private let encoder = JSONEncoder()
//
//    /// Last snapshot cached so new SSE clients can get something immediately.
//    public private(set) var lastSnapshotData: Data?
//
//    public init() {}
//
//    public func stream() -> AsyncStream<LiveTimingState> {
//        AsyncStream { continuation in
//            self.continuation = continuation
//            if let data = self.lastSnapshotData,
//               let snapshot = try? JSONDecoder().decode(LiveTimingState.self, from: data) {
//                continuation.yield(snapshot)
//            }
//        }
//    }
//
//    public func apply(_ message: LiveTimingMessage) {
//        switch message {
//        case .fullSnapshot(let hb):
//            if let td = hb.timingData { state.timingData = td }
//            if let ts = hb.timingStats { state.timingStats = ts }
////            if let cd = hb.carData { state.carData = cd }
////            if let pos = hb.positionData { state.positions = pos }
//            if let w = hb.weatherData { state.weather = w }
//        case .heartbeat(let hb):
////            if let td = hb.timingData { state.timingData = td }
////            if let ts = hb.timingStats { state.timingStats = ts }
////            if let cd = hb.carData { state.carData = cd }
////            if let pos = hb.positionData { state.positions = pos }
////            if let w = hb.weatherData { state.weather = w }
//            break
//
//        case .timingData(let delta):
//            break
//            //state.timingData.merge(with: delta)
//
//        case .carData(let delta):
//            state.carData.merge(with: delta)
//
//        case .position(let delta):
//            state.positions.merge(with: delta)
//
//        case .weather(let delta):
//            state.weather.merge(with: delta)
//
//        case .raw:
//            break
//        }
//
//        continuation?.yield(state)
//        // Update snapshot cache
//        if let data = try? encoder.encode(state) {
//            lastSnapshotData = data
//        }
//    }
//}
