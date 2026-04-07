//
//  SolarCalculator.swift
//  GoldenHour
//
//  Created by Eugene Kovs on 07.04.2026.
//  https://github.com/kovs705
//

import CoreLocation
import Foundation
import SwiftUI

/// The primary interface for all solar calculations.
/// Stateless, thread-safe value type. All computations are pure functions.
///
/// Usage:
/// ```swift
/// let calculator = SolarCalculator()
/// let events = calculator.events(
///   for: Date(),
///   at: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.006),
///   timeZone: TimeZone(identifier: "America/New_York")!
/// )
/// ```
public struct SolarCalculator: Sendable {

  public init() {}

  // MARK: - Zenith angles

  /// Standard zenith angles for twilight boundaries.
  private enum Zenith {
    static let official = 90.833       // 90 deg 50'
    static let civil = 96.0            // 6 deg below horizon
    static let nautical = 102.0        // 12 deg below horizon
    static let astronomical = 108.0    // 18 deg below horizon
    static let goldenHourLow = 94.0    // -4 deg (golden hour start / blue hour end)
    static let goldenHourHigh = 84.0   // +6 deg (golden hour end / day start)
    static let blueHourLow = 96.0      // -6 deg (same as civil)
  }

  // MARK: - Events

  /// Compute all sun event times for a given date and location.
  ///
  /// - Parameters:
  ///   - date: The date to compute events for (the calendar day in the given timezone is used).
  ///   - coordinate: The observer's geographic coordinate.
  ///   - timeZone: The timezone at the observer's location. Do NOT use the device's
  ///     local timezone unless the device is at the coordinate.
  /// - Returns: A `SolarEvents` struct with all computed event times.
  public func events(
    for date: Date,
    at coordinate: CLLocationCoordinate2D,
    timeZone: TimeZone = .gmt
  ) -> SolarEvents {
    // Compute all event times using the Ed Williams algorithm
    let rise = { (zenith: Double) in
      SunEventEngine.eventTime(
        type: .rise, date: date, coordinate: coordinate,
        zenith: zenith, timeZone: timeZone
      )
    }
    let set = { (zenith: Double) in
      SunEventEngine.eventTime(
        type: .set, date: date, coordinate: coordinate,
        zenith: zenith, timeZone: timeZone
      )
    }

    let officialSunrise = rise(Zenith.official)
    let officialSunset = set(Zenith.official)

    // Determine polar conditions
    let isPolar = officialSunrise == nil && officialSunset == nil
    var isMidnightSun = false
    var isPolarNight = false

    if isPolar {
      // Check sun altitude at solar noon to determine which polar condition
      let components = DateUtilities.dateComponents(from: date, in: timeZone)
      if let year = components.year, let month = components.month, let day = components.day {
        let eqTime = equationOfTime(year: year, month: month, day: day)
        if let noon = DateUtilities.solarNoon(
          year: year, month: month, day: day,
          longitude: coordinate.longitude, eqTime: eqTime
        ) {
          let pos = SolarPositionEngine.position(at: noon, coordinate: coordinate)
          isMidnightSun = pos.altitude > -0.833
          isPolarNight = !isMidnightSun
        }
      }
    }

    // Solar noon
    var solarNoon: Date?
    let components = DateUtilities.dateComponents(from: date, in: timeZone)
    if let year = components.year, let month = components.month, let day = components.day {
      let eqTime = equationOfTime(year: year, month: month, day: day)
      solarNoon = DateUtilities.solarNoon(
        year: year, month: month, day: day,
        longitude: coordinate.longitude, eqTime: eqTime
      )
    }

    return SolarEvents(
      astronomicalDawn: rise(Zenith.astronomical),
      astronomicalDusk: set(Zenith.astronomical),
      nauticalDawn: rise(Zenith.nautical),
      nauticalDusk: set(Zenith.nautical),
      civilDawn: rise(Zenith.civil),
      civilDusk: set(Zenith.civil),
      sunrise: officialSunrise,
      sunset: officialSunset,
      goldenHourMorningStart: rise(Zenith.goldenHourLow),
      goldenHourMorningEnd: rise(Zenith.goldenHourHigh),
      goldenHourEveningStart: set(Zenith.goldenHourHigh),
      goldenHourEveningEnd: set(Zenith.goldenHourLow),
      blueHourMorningStart: rise(Zenith.blueHourLow),
      blueHourMorningEnd: rise(Zenith.goldenHourLow),
      blueHourEveningStart: set(Zenith.goldenHourLow),
      blueHourEveningEnd: set(Zenith.blueHourLow),
      solarNoon: solarNoon,
      isMidnightSun: isMidnightSun,
      isPolarNight: isPolarNight
    )
  }

  // MARK: - Position

  /// Compute the sun's position (altitude and azimuth) at a specific instant.
  ///
  /// - Parameters:
  ///   - date: The exact instant to compute position for.
  ///   - coordinate: The observer's geographic coordinate.
  /// - Returns: A `SolarPosition` with altitude and azimuth in degrees.
  public func position(
    at date: Date,
    coordinate: CLLocationCoordinate2D
  ) -> SolarPosition {
    let pos = SolarPositionEngine.position(at: date, coordinate: coordinate)
    return SolarPosition(altitude: pos.altitude, azimuth: pos.azimuth)
  }

  // MARK: - Phase

  /// Determine the twilight phase at a specific instant and location.
  ///
  /// - Parameters:
  ///   - date: The instant to classify.
  ///   - coordinate: The observer's geographic coordinate.
  /// - Returns: The current `TwilightPhase`.
  public func phase(
    at date: Date,
    coordinate: CLLocationCoordinate2D
  ) -> TwilightPhase {
    let pos = SolarPositionEngine.position(at: date, coordinate: coordinate)
    return TwilightPhase.from(altitude: pos.altitude)
  }

  // MARK: - Gradient

  /// Generate a sky gradient for the current sun position.
  ///
  /// - Parameters:
  ///   - date: The instant to generate colors for.
  ///   - coordinate: The observer's geographic coordinate.
  /// - Returns: A `SkyGradient` containing an array of SwiftUI Colors.
  public func gradient(
    at date: Date,
    coordinate: CLLocationCoordinate2D
  ) -> SkyGradient {
    let pos = SolarPositionEngine.position(at: date, coordinate: coordinate)
    let rgbColors = GradientMapper.gradient(forAltitude: pos.altitude)
    let phase = TwilightPhase.from(altitude: pos.altitude)

    return SkyGradient(
      colors: rgbColors.map(\.swiftUIColor),
      sunAltitude: pos.altitude,
      phase: phase
    )
  }

  // MARK: - Private helpers

  private func equationOfTime(year: Int, month: Int, day: Int) -> Double {
    // Build a noon date for eq-of-time calculation
    guard let noonDate = DateUtilities.date(
      year: year, month: month, day: day, utcHours: 12.0
    ) else {
      return 0.0
    }
    return SolarPositionEngine.equationOfTime(for: noonDate)
  }
}
