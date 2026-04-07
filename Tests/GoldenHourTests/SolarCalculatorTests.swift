import CoreLocation
import XCTest
@testable import GoldenHour

final class SolarCalculatorTests: XCTestCase {

  private let calculator = SolarCalculator()

  // MARK: - Events

  func testEventsReturnsAllTimesForNYC() {
    let nyc = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.006)
    let tz = TimeZone(identifier: "America/New_York")!
    let date = makeDate(year: 2024, month: 6, day: 21, timeZone: tz)

    let events = calculator.events(for: date, at: nyc, timeZone: tz)

    // All events should be non-nil for NYC in summer
    XCTAssertNotNil(events.astronomicalDawn)
    XCTAssertNotNil(events.astronomicalDusk)
    XCTAssertNotNil(events.nauticalDawn)
    XCTAssertNotNil(events.nauticalDusk)
    XCTAssertNotNil(events.civilDawn)
    XCTAssertNotNil(events.civilDusk)
    XCTAssertNotNil(events.sunrise)
    XCTAssertNotNil(events.sunset)
    XCTAssertNotNil(events.goldenHourMorningStart)
    XCTAssertNotNil(events.goldenHourMorningEnd)
    XCTAssertNotNil(events.goldenHourEveningStart)
    XCTAssertNotNil(events.goldenHourEveningEnd)
    XCTAssertNotNil(events.blueHourMorningStart)
    XCTAssertNotNil(events.blueHourMorningEnd)
    XCTAssertNotNil(events.blueHourEveningStart)
    XCTAssertNotNil(events.blueHourEveningEnd)
    XCTAssertNotNil(events.solarNoon)
    XCTAssertFalse(events.isMidnightSun)
    XCTAssertFalse(events.isPolarNight)
  }

  func testEventOrderingMakeSense() throws {
    let nyc = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.006)
    let tz = TimeZone(identifier: "America/New_York")!
    let date = makeDate(year: 2024, month: 6, day: 21, timeZone: tz)

    let events = calculator.events(for: date, at: nyc, timeZone: tz)

    // Morning events should be in order: astronomical < nautical < civil < sunrise
    let astDawn = try XCTUnwrap(events.astronomicalDawn)
    let nauDawn = try XCTUnwrap(events.nauticalDawn)
    let civDawn = try XCTUnwrap(events.civilDawn)
    let sunrise = try XCTUnwrap(events.sunrise)
    let noon = try XCTUnwrap(events.solarNoon)
    let sunset = try XCTUnwrap(events.sunset)

    XCTAssertTrue(astDawn < nauDawn, "Astronomical dawn should be before nautical dawn")
    XCTAssertTrue(nauDawn < civDawn, "Nautical dawn should be before civil dawn")
    XCTAssertTrue(civDawn < sunrise, "Civil dawn should be before sunrise")
    XCTAssertTrue(sunrise < noon, "Sunrise should be before solar noon")
    XCTAssertTrue(noon < sunset, "Solar noon should be before sunset")
  }

  func testGoldenHourContainsSunrise() throws {
    let nyc = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.006)
    let tz = TimeZone(identifier: "America/New_York")!
    let date = makeDate(year: 2024, month: 6, day: 21, timeZone: tz)

    let events = calculator.events(for: date, at: nyc, timeZone: tz)

    let ghStart = try XCTUnwrap(events.goldenHourMorningStart)
    let ghEnd = try XCTUnwrap(events.goldenHourMorningEnd)
    let sunrise = try XCTUnwrap(events.sunrise)

    XCTAssertTrue(
      ghStart < sunrise && sunrise < ghEnd,
      "Sunrise should fall within morning golden hour"
    )
  }

  // MARK: - Position

  func testPositionReturnsReasonableValues() {
    let london = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
    let date = makeUTCDate(year: 2024, month: 6, day: 21, hour: 12, minute: 0)

    let pos = calculator.position(at: date, coordinate: london)

    XCTAssertTrue(pos.altitude > 50 && pos.altitude < 70, "London noon altitude should be ~62 deg")
    XCTAssertTrue(pos.azimuth >= 0 && pos.azimuth < 360, "Azimuth out of range")
  }

  // MARK: - Phase

  func testPhaseAtNoonIsDay() {
    let nyc = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.006)
    let date = makeUTCDate(year: 2024, month: 6, day: 21, hour: 17, minute: 0)

    let phase = calculator.phase(at: date, coordinate: nyc)

    XCTAssertEqual(phase, .day)
  }

  func testPhaseAtMidnightIsNight() {
    let nyc = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.006)
    // Midnight EDT = 4:00 UTC
    let date = makeUTCDate(year: 2024, month: 6, day: 21, hour: 4, minute: 0)

    let phase = calculator.phase(at: date, coordinate: nyc)

    XCTAssertTrue(
      phase == .night || phase == .astronomicalTwilight,
      "Expected night-ish phase at midnight, got \(phase)"
    )
  }

  // MARK: - Gradient

  func testGradientReturns32Colors() {
    let nyc = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.006)
    let date = makeUTCDate(year: 2024, month: 6, day: 21, hour: 17, minute: 0)

    let gradient = calculator.gradient(at: date, coordinate: nyc)

    XCTAssertEqual(gradient.colors.count, 32)
    XCTAssertEqual(gradient.phase, .day)
    XCTAssertTrue(gradient.sunAltitude > 0)
  }

  func testGradientDiffersForDayAndNight() {
    let nyc = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.006)

    let dayDate = makeUTCDate(year: 2024, month: 6, day: 21, hour: 17, minute: 0)
    let nightDate = makeUTCDate(year: 2024, month: 6, day: 21, hour: 4, minute: 0)

    let dayGradient = calculator.gradient(at: dayDate, coordinate: nyc)
    let nightGradient = calculator.gradient(at: nightDate, coordinate: nyc)

    XCTAssertNotEqual(dayGradient.phase, nightGradient.phase)
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
