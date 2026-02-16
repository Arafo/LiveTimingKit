import XCTest
@testable import LiveTimingKit

final class LiveTimingKitCoreTests: XCTestCase {
    func testTimingDataMergeUpdatesExistingLineAndAddsNewLine() {
        var current = TimingData(
            lines: [
                "44": TimingDataLine(gapToLeader: "0.000", position: "1")
            ],
            withheld: false,
            kf: false
        )
        let delta = TimingData(
            lines: [
                "44": TimingDataLine(gapToLeader: "+1.234", inPit: true),
                "16": TimingDataLine(position: "2")
            ],
            withheld: true,
            kf: true
        )

        current.merge(with: delta)

        XCTAssertEqual(current.lines["44"]?.position, "1")
        XCTAssertEqual(current.lines["44"]?.gapToLeader, "+1.234")
        XCTAssertEqual(current.lines["44"]?.inPit, true)
        XCTAssertEqual(current.lines["16"]?.position, "2")
        XCTAssertEqual(current.withheld, true)
        XCTAssertEqual(current.kf, true)
    }

    func testProcessEventUpdatesHeartbeatState() async throws {
        let processor = LiveTimingDefaultEventProcessor()
        let event = RawEvent(
            topic: Topic.heartbeat.rawValue,
            payload: AnyCodable(Heartbeat(utc: "2024-03-02T10:00:00Z", kf: true)),
            timestamp: .now
        )

        try await processor.process(event: event)
        let state = await processor.state

        XCTAssertEqual(state.heartbeat.utc, "2024-03-02T10:00:00Z")
        XCTAssertEqual(state.heartbeat.kf, true)
    }

    func testProcessSnapshotPopulatesState() async throws {
        let processor = LiveTimingDefaultEventProcessor()
        let snapshot = makeEnvelope(
            heartbeat: Heartbeat(utc: "2024-03-02T11:00:00Z", kf: false),
            lapCount: LapCount(currentLap: 15, totalLaps: 58)
        )

        try await processor.process(snapshot: snapshot)
        let state = await processor.state

        XCTAssertEqual(state.heartbeat.utc, "2024-03-02T11:00:00Z")
        XCTAssertEqual(state.lapCount.currentLap, 15)
        XCTAssertEqual(state.lapCount.totalLaps, 58)
    }

    private func makeEnvelope(
        heartbeat: Heartbeat? = nil,
        lapCount: LapCount? = nil
    ) -> Envelope {
        Envelope(
            heartbeat: heartbeat,
            extrapolatedClock: nil,
            topThree: nil,
            timingStats: nil,
            timingAppData: nil,
            weatherData: nil,
            trackStatus: nil,
            driverList: nil,
            raceControlMessages: nil,
            sessionInfo: nil,
            sessionData: nil,
            lapCount: lapCount,
            timingData: nil,
            teamRadio: nil,
            tyreStintSeries: nil,
            championshipPrediction: nil,
            pitStopSeries: nil,
            pitLaneTimeCollection: nil,
            carData: nil,
            position: nil,
            positionZ: nil
        )
    }
}
