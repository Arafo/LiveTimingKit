import Foundation
import XCTest
@testable import LiveTimingKit

final class TyreStintSeriesDecodingTests: XCTestCase {
    func testDecodesArrayStints() throws {
        let json = """
        {
          "Stints": {
            "31": [
              {
                "Compound": "HARD",
                "New": "true",
                "TyresNotChanged": "0",
                "TotalLaps": 1,
                "StartLaps": 0
              }
            ]
          }
        }
        """

        let decoded = try JSONDecoder().decode(TyreStintSeries.self, from: Data(json.utf8))

        XCTAssertEqual(decoded.stints["31"]?.count, 1)
        XCTAssertEqual(decoded.stints["31"]?.first?.compound, .hard)
        XCTAssertEqual(decoded.stints["31"]?.first?.startLaps, 0)
    }

    func testDecodesDictionaryStintsInNumericOrder() throws {
        let json = """
        {
          "Stints": {
            "31": {
              "1": {
                "Compound": "MEDIUM",
                "New": "true",
                "TyresNotChanged": "0",
                "TotalLaps": 3,
                "StartLaps": 3
              },
              "0": {
                "Compound": "HARD",
                "New": "true",
                "TyresNotChanged": "0",
                "TotalLaps": 2,
                "StartLaps": 0
              }
            }
          }
        }
        """

        let decoded = try JSONDecoder().decode(TyreStintSeries.self, from: Data(json.utf8))
        let compounds = decoded.stints["31"]?.map(\.compound)
        let startLaps = decoded.stints["31"]?.map(\.startLaps)

        XCTAssertEqual(compounds, [.hard, .medium])
        XCTAssertEqual(startLaps, [0, 3])
    }
}
