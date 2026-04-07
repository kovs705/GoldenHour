import CoreLocation
import XCTest
@testable import GoldenHour

final class SunEventEngineTests: XCTestCase {

  // MARK: - Known value tests

  /// Test sunrise/sunset for NYC on March 20, 2026 (spring equinox).
  /// Expected (from NOAA): sunrise ~10:59 UTC, sunset ~23:08 UTC
  func testNYCSpringEquinox() throws {
    let nyc = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.006)
    let tz = TimeZone(identifier: "America/New_York")!
    let date = makeDate(year: 2026, month: 3, day: 20, timeZone: tz)

    let sunrise = SunEventEngine.eventTime(
      type: .rise, date: date, coordinate: nyc,
      zenith: 90.833, timeZone: tz
    )
    let sunset = SunEventEngine.eventTime(
      type: .set, date: date, coordinate: nyc,
      zenith: 90.833, timeZone: tz
    )

    let sunriseUTC = try XCTUnwrap(sunrise)
    let sunsetUTC = try XCTUnwrap(sunset)

    // Sunrise should be around 10:59 UTC (6:59 EDT)
    let srComps = Calendar.utc.dateComponents([.hour, .minute], from: sunriseUTC)
    XCTAssertEqual(srComps.hour, 10, accuracy: 1, "Sunrise hour off")
    XCTAssertTrue(abs((srComps.minute ?? 0) - 59) < 5, "Sunrise minute off by more than 5")

    // Sunset should be around 23:08 UTC (19:08 EDT)
    let ssComps = Calendar.utc.dateComponents([.hour, .minute], from: sunsetUTC)
    XCTAssertEqual(ssComps.hour, 23, accuracy: 1, "Sunset hour off")
    XCTAssertTrue(abs((ssComps.minute ?? 0) - 8) < 5, "Sunset minute off by more than 5")
  }

  /// Test for Sydney, Australia (southern hemisphere) on June 21, 2026 (winter solstice).
  /// Expected: sunrise ~20:53 UTC (prev day), sunset ~07:53 UTC
  func testSydneyWinterSolstice() throws {
    let sydney = CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
    let tz = TimeZone(identifier: "Australia/Sydney")!
    let date = makeDate(year: 2026, month: 4, day: 6, timeZone: tz)

    let sunrise = SunEventEngine.eventTime(
      type: .rise, date: date, coordinate: sydney,
      zenith: 90.833, timeZone: tz
    )
    let sunset = SunEventEngine.eventTime(
      type: .set, date: date, coordinate: sydney,
      zenith: 90.833, timeZone: tz
    )

    XCTAssertNotNil(sunrise, "Sydney should have a sunrise in June")
    XCTAssertNotNil(sunset, "Sydney should have a sunset in June")
  }

  /// Test for Singapore (near equator) — should always have sunrise/sunset.
  func testSingaporeEquatorial() throws {
    let singapore = CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
    let tz = TimeZone(identifier: "Asia/Singapore")!

    // Test multiple dates throughout the year
    for month in [1, 4, 7, 10] {
      let date = makeDate(year: 2026, month: month, day: 15, timeZone: tz)

      let sunrise = SunEventEngine.eventTime(
        type: .rise, date: date, coordinate: singapore,
        zenith: 90.833, timeZone: tz
      )
      let sunset = SunEventEngine.eventTime(
        type: .set, date: date, coordinate: singapore,
        zenith: 90.833, timeZone: tz
      )

      XCTAssertNotNil(sunrise, "Singapore should always have sunrise (month \(month))")
      XCTAssertNotNil(sunset, "Singapore should always have sunset (month \(month))")
    }
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

// MARK: - Calendar helper

extension Calendar {
  fileprivate static var utc: Calendar {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(identifier: "UTC")!
    return cal
  }
}

// MARK: - XCTAssertEqual with accuracy for Int

private func XCTAssertEqual(
  _ value: Int?,
  _ expected: Int,
  accuracy: Int,
  _ message: String,
  file: StaticString = #filePath,
  line: UInt = #line
) {
  guard let value else {
    XCTFail("Value is nil. \(message)", file: file, line: line)
    return
  }
  XCTAssertTrue(
    abs(value - expected) <= accuracy,
    "\(message): \(value) is not within \(accuracy) of \(expected)",
    file: file,
    line: line
  )
}
