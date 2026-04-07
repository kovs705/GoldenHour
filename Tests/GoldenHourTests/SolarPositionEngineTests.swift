import CoreLocation
import XCTest
@testable import GoldenHour

final class SolarPositionEngineTests: XCTestCase {

  /// At solar noon in NYC on spring equinox, sun altitude should be ~49 degrees.
  /// (90 - latitude ≈ 90 - 40.7 = 49.3)
  func testNYCSolarNoonAltitude() {
    let nyc = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.006)

    // March 20, 2024 ~17:00 UTC is approximately solar noon for NYC
    let date = makeUTCDate(year: 2024, month: 3, day: 20, hour: 17, minute: 0)
    let pos = SolarPositionEngine.position(at: date, coordinate: nyc)

    // Sun altitude at noon on equinox should be approximately 90 - latitude
    XCTAssertTrue(
      pos.altitude > 40.0 && pos.altitude < 58.0,
      "Expected altitude ~49 deg at equinox noon, got \(pos.altitude)"
    )
  }

  /// At midnight UTC, sun should be below horizon for NYC.
  func testNYCMidnightBelowHorizon() {
    let nyc = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.006)
    let date = makeUTCDate(year: 2024, month: 6, day: 21, hour: 4, minute: 0)

    let pos = SolarPositionEngine.position(at: date, coordinate: nyc)

    // At midnight local (4 UTC in summer), sun should be well below horizon
    XCTAssertTrue(
      pos.altitude < 0,
      "Expected negative altitude at midnight, got \(pos.altitude)"
    )
  }

  /// Azimuth should be roughly east (~90) at sunrise and west (~270) at sunset.
  func testAzimuthDirections() {
    let nyc = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.006)

    // Approximate sunrise time: March 20, ~11:00 UTC
    let sunriseDate = makeUTCDate(year: 2024, month: 3, day: 20, hour: 11, minute: 0)
    let srPos = SolarPositionEngine.position(at: sunriseDate, coordinate: nyc)
    XCTAssertTrue(
      srPos.azimuth > 60 && srPos.azimuth < 120,
      "Expected easterly azimuth at sunrise, got \(srPos.azimuth)"
    )

    // Approximate sunset time: March 20, ~23:08 UTC
    let sunsetDate = makeUTCDate(year: 2024, month: 3, day: 20, hour: 23, minute: 8)
    let ssPos = SolarPositionEngine.position(at: sunsetDate, coordinate: nyc)
    XCTAssertTrue(
      ssPos.azimuth > 240 && ssPos.azimuth < 300,
      "Expected westerly azimuth at sunset, got \(ssPos.azimuth)"
    )
  }

  /// Near the equator on equinox, noon altitude should be near 90 degrees.
  func testEquatorEquinoxNoon() {
    let equator = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    // March 20, 12:00 UTC — solar noon at longitude 0
    let date = makeUTCDate(year: 2024, month: 3, day: 20, hour: 12, minute: 0)
    let pos = SolarPositionEngine.position(at: date, coordinate: equator)

    XCTAssertTrue(
      pos.altitude > 80.0,
      "Expected near-vertical sun at equator on equinox, got \(pos.altitude)"
    )
  }

  // MARK: - Helpers

  private func makeUTCDate(
    year: Int, month: Int, day: Int,
    hour: Int, minute: Int
  ) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    var comps = DateComponents()
    comps.year = year
    comps.month = month
    comps.day = day
    comps.hour = hour
    comps.minute = minute
    comps.second = 0
    return calendar.date(from: comps)!
  }
}
