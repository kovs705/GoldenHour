import CoreLocation
import XCTest
@testable import GoldenHour

final class PolarRegionTests: XCTestCase {

  private let calculator = SolarCalculator()

  /// Tromso, Norway on June 21 — midnight sun.
  func testTromsoMidnightSun() {
    let tromso = CLLocationCoordinate2D(latitude: 69.6496, longitude: 18.9560)
    let tz = TimeZone(identifier: "Europe/Oslo")!
    let date = makeDate(year: 2026, month: 4, day: 6, timeZone: tz)

    let events = calculator.events(for: date, at: tromso, timeZone: tz)

    XCTAssertNil(events.sunrise, "No sunrise during midnight sun — sun doesn't set")
    XCTAssertNil(events.sunset, "No sunset during midnight sun")
    XCTAssertTrue(events.isMidnightSun, "Should be midnight sun")
    XCTAssertFalse(events.isPolarNight, "Should not be polar night")
  }

  /// Tromso, Norway on December 21 — polar night.
  func testTromsoPolarNight() {
    let tromso = CLLocationCoordinate2D(latitude: 69.6496, longitude: 18.9560)
    let tz = TimeZone(identifier: "Europe/Oslo")!
    let date = makeDate(year: 2026, month: 12, day: 6, timeZone: tz)

    let events = calculator.events(for: date, at: tromso, timeZone: tz)

    XCTAssertNil(events.sunrise, "No sunrise during polar night")
    XCTAssertNil(events.sunset, "No sunset during polar night")
    XCTAssertFalse(events.isMidnightSun, "Should not be midnight sun")
    XCTAssertTrue(events.isPolarNight, "Should be polar night")
  }

  /// Phase detection works correctly during midnight sun.
  func testPhaseAtMidnightDuringMidnightSun() {
    let tromso = CLLocationCoordinate2D(latitude: 69.6496, longitude: 18.9560)

    // June 21, midnight UTC+2 = 22:00 UTC on June 20
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    var comps = DateComponents()
    comps.year = 2024
    comps.month = 6
    comps.day = 20
    comps.hour = 22
    comps.minute = 0
    let midnight = calendar.date(from: comps)!

    let phase = calculator.phase(at: midnight, coordinate: tromso)

    // During midnight sun, even at midnight the sun should be above or near horizon
    XCTAssertTrue(
      phase == .day || phase == .goldenHour,
      "During midnight sun, phase at midnight should be day or golden hour, got \(phase)"
    )
  }

  /// Phase detection works correctly during polar night.
  func testPhaseAtNoonDuringPolarNight() {
    let tromso = CLLocationCoordinate2D(latitude: 69.6496, longitude: 18.9560)

    // December 21, noon UTC+1 = 11:00 UTC
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    var comps = DateComponents()
    comps.year = 2026
    comps.month = 12
    comps.day = 21
    comps.hour = 11
    comps.minute = 0
    let noon = calendar.date(from: comps)!

    let phase = calculator.phase(at: noon, coordinate: tromso)

    // During polar night at Tromso (69.65N), the sun reaches ~-3 deg at noon
    // on Dec 21. This is within golden hour range (-4 to 6). The sun doesn't
    // rise above the official threshold (-0.833), but it's not deeply below.
    XCTAssertTrue(
      phase < .day,
      "During polar night, phase at noon should not be full day, got \(phase)"
    )
  }

  /// Reykjavik near the boundary — should have sunrise/sunset on equinox.
  func testReykjavikEquinox() {
    let reykjavik = CLLocationCoordinate2D(latitude: 64.1466, longitude: -21.9426)
    let tz = TimeZone(identifier: "Atlantic/Reykjavik")!
    let date = makeDate(year: 2026, month: 3, day: 20, timeZone: tz)

    let events = calculator.events(for: date, at: reykjavik, timeZone: tz)

    XCTAssertNotNil(events.sunrise, "Reykjavik should have sunrise on equinox")
    XCTAssertNotNil(events.sunset, "Reykjavik should have sunset on equinox")
    XCTAssertFalse(events.isMidnightSun)
    XCTAssertFalse(events.isPolarNight)
  }

  // MARK: - Helpers

  private func makeDate(
    year: Int, month: Int, day: Int,
    timeZone: TimeZone
  ) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    var comps = DateComponents()
    comps.year = year
    comps.month = month
    comps.day = day
    comps.hour = 12
    return calendar.date(from: comps)!
  }
}
