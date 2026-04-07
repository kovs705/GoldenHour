import XCTest
@testable import GoldenHour

final class TwilightPhaseTests: XCTestCase {

  func testPhaseClassification() {
    XCTAssertEqual(TwilightPhase.from(altitude: -25), .night)
    XCTAssertEqual(TwilightPhase.from(altitude: -18), .astronomicalTwilight)
    XCTAssertEqual(TwilightPhase.from(altitude: -15), .astronomicalTwilight)
    XCTAssertEqual(TwilightPhase.from(altitude: -12), .nauticalTwilight)
    XCTAssertEqual(TwilightPhase.from(altitude: -9), .nauticalTwilight)
    XCTAssertEqual(TwilightPhase.from(altitude: -6), .blueHour)
    XCTAssertEqual(TwilightPhase.from(altitude: -5), .blueHour)
    XCTAssertEqual(TwilightPhase.from(altitude: -4), .goldenHour)
    XCTAssertEqual(TwilightPhase.from(altitude: -2), .goldenHour)
    XCTAssertEqual(TwilightPhase.from(altitude: 0), .goldenHour)
    XCTAssertEqual(TwilightPhase.from(altitude: 3), .goldenHour)
    XCTAssertEqual(TwilightPhase.from(altitude: 5.9), .goldenHour)
    XCTAssertEqual(TwilightPhase.from(altitude: 6), .day)
    XCTAssertEqual(TwilightPhase.from(altitude: 45), .day)
    XCTAssertEqual(TwilightPhase.from(altitude: 90), .day)
  }

  func testPhaseOrdering() {
    XCTAssertTrue(TwilightPhase.night < .astronomicalTwilight)
    XCTAssertTrue(TwilightPhase.astronomicalTwilight < .nauticalTwilight)
    XCTAssertTrue(TwilightPhase.nauticalTwilight < .blueHour)
    XCTAssertTrue(TwilightPhase.blueHour < .goldenHour)
    XCTAssertTrue(TwilightPhase.goldenHour < .day)
  }

  func testCaseIterable() {
    XCTAssertEqual(TwilightPhase.allCases.count, 6)
    XCTAssertEqual(TwilightPhase.allCases.first, .night)
    XCTAssertEqual(TwilightPhase.allCases.last, .day)
  }

  func testBoundaryValues() {
    // Exact boundary at -18
    XCTAssertEqual(TwilightPhase.from(altitude: -18.0), .astronomicalTwilight)
    XCTAssertEqual(TwilightPhase.from(altitude: -18.001), .night)

    // Exact boundary at -12
    XCTAssertEqual(TwilightPhase.from(altitude: -12.0), .nauticalTwilight)
    XCTAssertEqual(TwilightPhase.from(altitude: -12.001), .astronomicalTwilight)

    // Exact boundary at -6
    XCTAssertEqual(TwilightPhase.from(altitude: -6.0), .blueHour)
    XCTAssertEqual(TwilightPhase.from(altitude: -6.001), .nauticalTwilight)

    // Exact boundary at -4
    XCTAssertEqual(TwilightPhase.from(altitude: -4.0), .goldenHour)
    XCTAssertEqual(TwilightPhase.from(altitude: -4.001), .blueHour)

    // Exact boundary at 6
    XCTAssertEqual(TwilightPhase.from(altitude: 6.0), .day)
    XCTAssertEqual(TwilightPhase.from(altitude: 5.999), .goldenHour)
  }
}
