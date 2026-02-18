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

    func testTimingAppDataDecodesSingleStintObjectAsArray() throws {
        let json = """
        {
          "Lines": {
            "10": {
              "Stints": {
                "Compound": "SOFT",
                "TotalLaps": 9
              }
            }
          }
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(TimingAppData.self, from: json)

        guard case let .array(stints)? = decoded.lines["10"]?.stints else {
            XCTFail("Expected Stints to decode as array")
            return
        }

        XCTAssertEqual(stints.count, 1)
        XCTAssertEqual(stints.first?.compound, .soft)
        XCTAssertEqual(stints.first?.totalLaps, 9)
    }

    func testTimingAppDataDecodesStintsDictionary() throws {
        let json = """
        {
          "Lines": {
            "10": {
              "Stints": {
                "0": {
                  "Compound": "MEDIUM",
                  "TotalLaps": 12
                }
              }
            }
          }
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(TimingAppData.self, from: json)

        guard case let .dictionary(stints)? = decoded.lines["10"]?.stints else {
            XCTFail("Expected Stints to decode as dictionary")
            return
        }

        XCTAssertEqual(stints["0"]?.compound, .medium)
        XCTAssertEqual(stints["0"]?.totalLaps, 12)
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
