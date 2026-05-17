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

    func testTimingDataMergeCarriesSessionPartBecauseQualifyingUsesItForCurrentSegment() {
        var current = TimingData(lines: [:], sessionPart: 1)
        let delta = TimingData(lines: [:], sessionPart: 2)

        current.merge(with: delta)

        XCTAssertEqual(current.sessionPart, 2)
    }

    func testDecodesQualifyingPartFromSessionDataSeries() throws {
        let data = Data("""
        {
          "Series": {
            "0": {
              "Utc": "2026-03-13T07:17:21.552Z",
              "QualifyingPart": 2
            }
          }
        }
        """.utf8)

        let sessionData = try JSONDecoder().decode(SessionData.self, from: data)

        XCTAssertEqual(sessionData.series.first?.qualifyingPart, 2)
    }

    func testDecodesSessionPartFromTimingDataAndTopThree() throws {
        let timingData = try JSONDecoder().decode(
            TimingData.self,
            from: Data(#"{"SessionPart":3,"Lines":{},"Withheld":false}"#.utf8)
        )
        let topThree = try JSONDecoder().decode(
            TopThree.self,
            from: Data(#"{"SessionPart":1,"Lines":[],"Withheld":false}"#.utf8)
        )

        XCTAssertEqual(timingData.sessionPart, 3)
        XCTAssertEqual(topThree.sessionPart, 1)
    }

    func testDecodesExtrapolatedClockUtc() throws {
        let clock = try JSONDecoder().decode(
            ExtrapolatedClock.self,
            from: Data(#"{"Utc":"2026-03-07T05:00:01.007Z","Remaining":"00:17:59","Extrapolating":true}"#.utf8)
        )

        XCTAssertTrue(clock.hasUtc)
        XCTAssertEqual(clock.remaining, "00:17:59")
        XCTAssertEqual(clock.extrapolating, true)
        XCTAssertEqual(clock.utc.timeIntervalSince1970, 1_772_859_601.007, accuracy: 0.001)
    }

    func testExtrapolatedClockMergePreservesMissingFields() {
        var clock = ExtrapolatedClock(
            utc: Date(timeIntervalSince1970: 1_772_859_601.007),
            remaining: "00:17:59",
            extrapolating: true,
            hasUtc: true
        )

        clock.merge(with: ExtrapolatedClock(remaining: "00:17:58", extrapolating: nil))

        XCTAssertTrue(clock.hasUtc)
        XCTAssertEqual(clock.utc.timeIntervalSince1970, 1_772_859_601.007, accuracy: 0.001)
        XCTAssertEqual(clock.remaining, "00:17:58")
        XCTAssertEqual(clock.extrapolating, true)
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

    func testProcessExtrapolatedClockDeltaMergesSparseUpdates() async throws {
        let processor = LiveTimingDefaultEventProcessor()
        let start = RawEvent(
            topic: Topic.extrapolatedClock.rawValue,
            payload: AnyCodable(ExtrapolatedClock(
                utc: Date(timeIntervalSince1970: 1_772_859_601.007),
                remaining: "00:17:59",
                extrapolating: true,
                hasUtc: true
            )),
            timestamp: .now
        )
        let tick = RawEvent(
            topic: Topic.extrapolatedClock.rawValue,
            payload: AnyCodable(ExtrapolatedClock(remaining: "00:17:58", extrapolating: nil)),
            timestamp: .now
        )

        try await processor.process(event: start)
        try await processor.process(event: tick)

        let state = await processor.state
        XCTAssertTrue(state.extrapolatedClock.hasUtc)
        XCTAssertEqual(state.extrapolatedClock.utc.timeIntervalSince1970, 1_772_859_601.007, accuracy: 0.001)
        XCTAssertEqual(state.extrapolatedClock.remaining, "00:17:58")
        XCTAssertEqual(state.extrapolatedClock.extrapolating, true)
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
