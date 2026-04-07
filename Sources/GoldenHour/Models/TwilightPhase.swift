//
//  TwilightPhase.swift
//  GoldenHour
//
//  Created by Eugene Kovs on 07.04.2026.
//  https://github.com/kovs705
//

import Foundation

/// Classifies the current solar illumination phase based on sun altitude.
/// Ordered from darkest to brightest.
public enum TwilightPhase: Int, CaseIterable, Sendable, Comparable {
  /// Sun more than 18 degrees below horizon. Sky is fully dark.
  case night = 0
  /// Sun between 12 and 18 degrees below horizon.
  case astronomicalTwilight = 1
  /// Sun between 6 and 12 degrees below horizon.
  case nauticalTwilight = 2
  /// Sun between 6 and 4 degrees below horizon. The blue hour sub-period.
  case blueHour = 3
  /// Sun between 4 degrees below and 6 degrees above horizon.
  case goldenHour = 4
  /// Sun more than 6 degrees above horizon. Full daylight.
  case day = 5

  public static func < (lhs: TwilightPhase, rhs: TwilightPhase) -> Bool {
    lhs.rawValue < rhs.rawValue
  }

  /// Classify the twilight phase from a sun altitude in degrees.
  public static func from(altitude: Double) -> TwilightPhase {
    switch altitude {
    case ..<(-18.0):
      return .night
    case -18.0 ..< -12.0:
      return .astronomicalTwilight
    case -12.0 ..< -6.0:
      return .nauticalTwilight
    case -6.0 ..< -4.0:
      return .blueHour
    case -4.0 ..< 6.0:
      return .goldenHour
    default:
      return .day
    }
  }
}
