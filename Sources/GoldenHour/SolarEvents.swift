import Foundation

/// All sun event times for a single calendar day at a specific location.
/// A nil value indicates the event does not occur on this day
/// (e.g., polar day or polar night).
public struct SolarEvents: Sendable {

  // MARK: - Astronomical twilight (sun 18 degrees below horizon)

  public let astronomicalDawn: Date?
  public let astronomicalDusk: Date?

  // MARK: - Nautical twilight (sun 12 degrees below horizon)

  public let nauticalDawn: Date?
  public let nauticalDusk: Date?

  // MARK: - Civil twilight (sun 6 degrees below horizon)

  public let civilDawn: Date?
  public let civilDusk: Date?

  // MARK: - Official sunrise/sunset (sun 50' below horizon)

  public let sunrise: Date?
  public let sunset: Date?

  // MARK: - Golden hour (sun between -4 and +6 degrees)

  /// Morning golden hour start (sun crosses -4 degrees rising).
  public let goldenHourMorningStart: Date?
  /// Morning golden hour end (sun crosses +6 degrees rising).
  public let goldenHourMorningEnd: Date?
  /// Evening golden hour start (sun crosses +6 degrees descending).
  public let goldenHourEveningStart: Date?
  /// Evening golden hour end (sun crosses -4 degrees descending).
  public let goldenHourEveningEnd: Date?

  // MARK: - Blue hour (sun between -6 and -4 degrees)

  /// Morning blue hour start (sun crosses -6 degrees rising).
  public let blueHourMorningStart: Date?
  /// Morning blue hour end (sun crosses -4 degrees rising).
  public let blueHourMorningEnd: Date?
  /// Evening blue hour start (sun crosses -4 degrees descending).
  public let blueHourEveningStart: Date?
  /// Evening blue hour end (sun crosses -6 degrees descending).
  public let blueHourEveningEnd: Date?

  // MARK: - Solar noon

  public let solarNoon: Date?

  // MARK: - Polar region indicators

  /// True if the sun never sets on this day (midnight sun).
  public let isMidnightSun: Bool
  /// True if the sun never rises on this day (polar night).
  public let isPolarNight: Bool
}
