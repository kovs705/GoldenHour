//
//  SolarPosition.swift
//  GoldenHour
//
//  Created by Eugene Kovs on 07.04.2026.
//  https://github.com/kovs705
//

import Foundation

/// The sun's position in the sky at a specific instant.
public struct SolarPosition: Sendable, Equatable {
  /// Sun's altitude (elevation) above the horizon in degrees.
  /// Positive values indicate the sun is above the horizon.
  /// Negative values indicate the sun is below the horizon.
  public let altitude: Double

  /// Sun's azimuth in degrees clockwise from north.
  /// 0 = north, 90 = east, 180 = south, 270 = west.
  public let azimuth: Double

  /// The twilight phase for this sun position.
  public var phase: TwilightPhase {
    TwilightPhase.from(altitude: altitude)
  }
}
