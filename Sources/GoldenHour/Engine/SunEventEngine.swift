//
//  SunEventEngine.swift
//  GoldenHour
//
//  Created by Eugene Kovs on 07.04.2026.
//  https://github.com/kovs705
//

import CoreLocation
import Foundation

/// Computes the UTC time when the sun crosses a given zenith angle,
/// using the Ed Williams Sunrise/Sunset algorithm.
/// Reference: https://edwilliams.org/sunrise_sunset_algorithm.htm
enum SunEventEngine {

  enum EventType {
    case rise
    case set
  }

  /// Compute the UTC Date when the sun crosses the given zenith angle.
  /// Returns nil if the event does not occur (polar regions).
  ///
  /// - Parameters:
  ///   - type: Whether computing a rise or set event.
  ///   - date: The date to compute for.
  ///   - coordinate: Observer's geographic coordinate.
  ///   - zenith: The zenith angle in degrees (e.g. 90.833 for official sunrise).
  ///   - timeZone: The observer's local timezone (used for correct day extraction).
  static func eventTime(
    type: EventType,
    date: Date,
    coordinate: CLLocationCoordinate2D,
    zenith: Double,
    timeZone: TimeZone
  ) -> Date? {
    let components = DateUtilities.dateComponents(from: date, in: timeZone)
    guard let year = components.year,
          let month = components.month,
          let day = components.day else {
      return nil
    }

    // Step 1: Day of year
    let n = dayOfYear(year: year, month: month, day: day)

    // Step 2: Approximate time
    let lngHour = coordinate.longitude / 15.0
    let t: Double
    switch type {
    case .rise:
      t = Double(n) + ((6.0 - lngHour) / 24.0)
    case .set:
      t = Double(n) + ((18.0 - lngHour) / 24.0)
    }

    // Step 3: Sun's mean anomaly
    let m = (0.9856 * t) - 3.289

    // Step 4: Sun's true longitude
    let mRad = m.degreesToRadians
    var l = m + (1.916 * sin(mRad)) + (0.020 * sin(2.0 * mRad)) + 282.634
    l = l.normalizedDegrees

    // Step 5: Right ascension
    let lRad = l.degreesToRadians
    var ra = atan(0.91764 * tan(lRad)).radiansToDegrees
    ra = ra.normalizedDegrees

    let lQuadrant = (floor(l / 90.0)) * 90.0
    let raQuadrant = (floor(ra / 90.0)) * 90.0
    ra += (lQuadrant - raQuadrant)

    // Convert RA to hours
    let raHours = ra / 15.0

    // Step 6: Sun's declination
    let sinDec = 0.39782 * sin(lRad)
    let cosDec = cos(asin(sinDec))

    // Step 7: Local hour angle
    let latRad = coordinate.latitude.degreesToRadians
    let zenithRad = zenith.degreesToRadians
    let cosH = (cos(zenithRad) - (sinDec * sin(latRad))) / (cosDec * cos(latRad))

    // Sun never rises/sets at this zenith for this location/date
    if cosH > 1.0 { return nil }  // Sun never reaches this zenith (stays below)
    if cosH < -1.0 { return nil } // Sun never goes below this zenith (stays above)

    let h: Double
    switch type {
    case .rise:
      h = (360.0 - acos(cosH).radiansToDegrees) / 15.0
    case .set:
      h = acos(cosH).radiansToDegrees / 15.0
    }

    // Step 8: Local mean time
    let localMeanTime = h + raHours - (0.06571 * t) - 6.622

    // Step 9: Adjust to UTC
    let ut = (localMeanTime - lngHour).normalizedHours

    // Build the result Date, handling day-boundary crossings.
    // The observer's calendar day may span two UTC days (e.g. NYC June 21 EDT
    // spans June 21 04:00 UTC to June 22 04:00 UTC). We need the result
    // to fall within the observer's calendar day.
    var observerCalendar = Calendar(identifier: .gregorian)
    observerCalendar.timeZone = timeZone
    let dayStart = observerCalendar.startOfDay(for: date)
    let dayEnd = dayStart.addingTimeInterval(86400)

    let utcComps = DateUtilities.utcComponents(from: dayStart)
    guard let utcYear = utcComps.year,
          let utcMonth = utcComps.month,
          let utcDay = utcComps.day,
          let candidate = DateUtilities.date(
            year: utcYear, month: utcMonth, day: utcDay, utcHours: ut
          ) else {
      return nil
    }

    if candidate >= dayStart && candidate < dayEnd {
      return candidate
    }

    // Try shifting ±1 day to land within the observer's calendar day
    let shifted = candidate < dayStart
      ? candidate.addingTimeInterval(86400)
      : candidate.addingTimeInterval(-86400)

    if shifted >= dayStart && shifted < dayEnd {
      return shifted
    }

    return candidate
  }

  // MARK: - Day of year (from date components, not Date object)

  private static func dayOfYear(year: Int, month: Int, day: Int) -> Int {
    let n1 = Int(floor(275.0 * Double(month) / 9.0))
    let n2 = Int(floor(Double(month + 9) / 12.0))
    let n3 = 1 + Int(floor(Double(year - 4 * Int(floor(Double(year) / 4.0)) + 2) / 3.0))
    return n1 - (n2 * n3) + day - 30
  }
}
