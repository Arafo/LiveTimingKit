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

    func testSessionInfoDerivesSessionKindFromFeedFields() throws {
        XCTAssertEqual(
            sessionInfo(type: "Practice", number: 3, name: "Practice 3").liveTimingSessionKind,
            .practice(3)
        )
        XCTAssertEqual(
            sessionInfo(type: "Qualifying", name: "Sprint Qualifying").liveTimingSessionKind,
            .sprintQualifying
        )
        XCTAssertEqual(
            sessionInfo(type: "Race", name: "Sprint").liveTimingSessionKind,
            .sprint
        )
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

    private func sessionInfo(
        type: String,
        number: Int? = nil,
        name: String
    ) -> SessionInfo {
        SessionInfo(
            meeting: nil,
            sessionStatus: nil,
            archiveStatus: nil,
            key: nil,
            type: type,
            number: number,
            name: name,
            startDate: nil,
            endDate: nil,
            gmtOffset: nil,
            path: nil,
            kf: nil,
            circuitPoints: nil,
            circuitCorners: nil,
            circuitRotation: nil
        )
    }
}
