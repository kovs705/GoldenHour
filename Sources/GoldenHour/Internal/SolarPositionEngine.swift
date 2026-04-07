import CoreLocation
import Foundation

/// Computes the sun's altitude and azimuth at any arbitrary instant
/// using NOAA General Solar Position formulas.
enum SolarPositionEngine {

  /// Compute the sun's altitude and azimuth at a specific instant.
  /// - Parameters:
  ///   - date: The exact instant to compute position for.
  ///   - coordinate: The observer's geographic coordinate.
  /// - Returns: A tuple of (altitude in degrees, azimuth in degrees clockwise from north).
  static func position(
    at date: Date,
    coordinate: CLLocationCoordinate2D
  ) -> (altitude: Double, azimuth: Double) {
    let comps = DateUtilities.utcComponents(from: date)
    let hour = Double(comps.hour ?? 0)
    let minute = Double(comps.minute ?? 0)
    let second = Double(comps.second ?? 0)

    let dayOfYear = Double(DateUtilities.dayOfYear(for: date))
    let daysInYear = Double(DateUtilities.daysInYear(for: date))

    // Fractional year (gamma) in radians
    let gamma = (2.0 * .pi / daysInYear) * (dayOfYear - 1.0 + (hour - 12.0) / 24.0)

    // Equation of time (minutes)
    let eqTime = 229.18 * (
      0.000075
      + 0.001868 * cos(gamma)
      - 0.032077 * sin(gamma)
      - 0.014615 * cos(2.0 * gamma)
      - 0.040849 * sin(2.0 * gamma)
    )

    // Solar declination (radians)
    let decl = 0.006918
      - 0.399912 * cos(gamma)
      + 0.070257 * sin(gamma)
      - 0.006758 * cos(2.0 * gamma)
      + 0.000907 * sin(2.0 * gamma)
      - 0.002697 * cos(3.0 * gamma)
      + 0.00148 * sin(3.0 * gamma)

    // True solar time (minutes)
    let utcMinutes = hour * 60.0 + minute + second / 60.0
    let tst = utcMinutes + eqTime + 4.0 * coordinate.longitude

    // Hour angle (degrees)
    let ha = (tst / 4.0) - 180.0
    let haRad = ha.degreesToRadians

    // Solar zenith angle
    let latRad = coordinate.latitude.degreesToRadians
    let cosZenith = sin(latRad) * sin(decl) + cos(latRad) * cos(decl) * cos(haRad)
    let zenithRad = acos(max(-1.0, min(1.0, cosZenith)))
    let altitude = 90.0 - zenithRad.radiansToDegrees

    // Solar azimuth
    let sinZenith = sin(zenithRad)
    var azimuth: Double
    if abs(sinZenith) < 1e-10 {
      // Sun is at zenith or nadir, azimuth is undefined
      azimuth = 0.0
    } else {
      let cosAzimuth = (sin(decl) - sin(latRad) * cosZenith) / (cos(latRad) * sinZenith)
      let clampedCosAz = max(-1.0, min(1.0, cosAzimuth))
      azimuth = acos(clampedCosAz).radiansToDegrees

      // If hour angle is positive, sun is in the west (azimuth > 180)
      if ha > 0 {
        azimuth = 360.0 - azimuth
      }
    }

    return (altitude: altitude, azimuth: azimuth)
  }

  /// Compute the equation of time for a given date (used for solar noon calculation).
  static func equationOfTime(for date: Date) -> Double {
    let dayOfYear = Double(DateUtilities.dayOfYear(for: date))
    let daysInYear = Double(DateUtilities.daysInYear(for: date))
    let gamma = (2.0 * .pi / daysInYear) * (dayOfYear - 1.0 + (12.0 - 12.0) / 24.0)

    return 229.18 * (
      0.000075
      + 0.001868 * cos(gamma)
      - 0.032077 * sin(gamma)
      - 0.014615 * cos(2.0 * gamma)
      - 0.040849 * sin(2.0 * gamma)
    )
  }
}
