//
//  GradientMapper.swift
//  GoldenHour
//
//  Created by Eugene Kovs on 07.04.2026.
//  https://github.com/kovs705
//

import Foundation

/// Maps a sun altitude to an array of sky gradient colors.
enum GradientMapper {

  /// Number of color stops in the generated gradient.
  static let colorStopCount = 32

  /// Generate an array of RGB colors representing the sky gradient
  /// from zenith (top) to horizon (bottom) for a given sun altitude.
  static func gradient(forAltitude altitude: Double) -> [RGB] {
    let (top, mid, horizon) = interpolatedKeyframe(forAltitude: altitude)
    return generateStops(top: top, mid: mid, horizon: horizon)
  }

  // MARK: - Keyframe interpolation

  /// Find the two bounding keyframes and interpolate between them.
  static func interpolatedKeyframe(
    forAltitude altitude: Double
  ) -> (top: RGB, mid: RGB, horizon: RGB) {
    let keyframes = SkyColorPalette.keyframes

    // Clamp to keyframe range
    if altitude <= keyframes[0].altitude {
      let kf = keyframes[0]
      return (kf.top, kf.mid, kf.horizon)
    }
    if altitude >= keyframes[keyframes.count - 1].altitude {
      let kf = keyframes[keyframes.count - 1]
      return (kf.top, kf.mid, kf.horizon)
    }

    // Find bounding keyframes
    var lower = keyframes[0]
    var upper = keyframes[1]
    for i in 1 ..< keyframes.count {
      if keyframes[i].altitude >= altitude {
        upper = keyframes[i]
        lower = keyframes[i - 1]
        break
      }
    }

    let range = upper.altitude - lower.altitude
    let t = range > 0 ? (altitude - lower.altitude) / range : 0.0

    return (
      top: lower.top.lerp(to: upper.top, t: t),
      mid: lower.mid.lerp(to: upper.mid, t: t),
      horizon: lower.horizon.lerp(to: upper.horizon, t: t)
    )
  }

  // MARK: - Generate stops from top → mid → horizon

  /// Generate `colorStopCount` color stops using smooth interpolation
  /// from top through mid to horizon.
  private static func generateStops(
    top: RGB,
    mid: RGB,
    horizon: RGB
  ) -> [RGB] {
    let count = colorStopCount
    var result = [RGB]()
    result.reserveCapacity(count)

    for i in 0 ..< count {
      let position = Double(i) / Double(count - 1) // 0.0 (top) to 1.0 (horizon)

      if position <= 0.5 {
        // Top half: interpolate from top to mid
        let t = position / 0.5
        // Use smoothstep for more natural transition
        let smooth = t * t * (3.0 - 2.0 * t)
        result.append(top.lerp(to: mid, t: smooth))
      } else {
        // Bottom half: interpolate from mid to horizon
        let t = (position - 0.5) / 0.5
        let smooth = t * t * (3.0 - 2.0 * t)
        result.append(mid.lerp(to: horizon, t: smooth))
      }
    }

    return result
  }
}
