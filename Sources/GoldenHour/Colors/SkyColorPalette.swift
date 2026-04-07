//
//  SkyColorPalette.swift
//  GoldenHour
//
//  Created by Eugene Kovs on 07.04.2026.
//  https://github.com/kovs705
//

import Foundation

/// An RGB color with components in [0, 1].
struct RGB: Sendable, Equatable {
  let r: Double
  let g: Double
  let b: Double

  /// Linear interpolation between two RGB colors.
  func lerp(to other: RGB, t: Double) -> RGB {
    let t = max(0.0, min(1.0, t))
    return RGB(
      r: r + (other.r - r) * t,
      g: g + (other.g - g) * t,
      b: b + (other.b - b) * t
    )
  }

  /// Create from hex integer (e.g. 0x0a0a2e).
  init(hex: Int) {
    r = Double((hex >> 16) & 0xFF) / 255.0
    g = Double((hex >> 8) & 0xFF) / 255.0
    b = Double(hex & 0xFF) / 255.0
  }

  init(r: Double, g: Double, b: Double) {
    self.r = r
    self.g = g
    self.b = b
  }
}

/// A keyframe mapping a sun altitude to three sky colors (top, mid, horizon).
struct SkyKeyframe: Sendable {
  let altitude: Double
  let top: RGB
  let mid: RGB
  let horizon: RGB
}

/// Defines the sky color palette as altitude-keyed keyframes.
enum SkyColorPalette {

  // swiftlint:disable function_body_length
  static let keyframes: [SkyKeyframe] = [
    // Deep night
    SkyKeyframe(
      altitude: -90,
      top: RGB(hex: 0x050516),
      mid: RGB(hex: 0x080820),
      horizon: RGB(hex: 0x0a0a2e)
    ),
    // Night
    SkyKeyframe(
      altitude: -18,
      top: RGB(hex: 0x0a0e28),
      mid: RGB(hex: 0x0e1438),
      horizon: RGB(hex: 0x141e50)
    ),
    // Astronomical twilight
    SkyKeyframe(
      altitude: -15,
      top: RGB(hex: 0x0e1438),
      mid: RGB(hex: 0x162048),
      horizon: RGB(hex: 0x1e2c62)
    ),
    // Nautical twilight start
    SkyKeyframe(
      altitude: -12,
      top: RGB(hex: 0x121a48),
      mid: RGB(hex: 0x1e2c5e),
      horizon: RGB(hex: 0x2e3e78)
    ),
    // Nautical twilight mid
    SkyKeyframe(
      altitude: -9,
      top: RGB(hex: 0x162060),
      mid: RGB(hex: 0x283878),
      horizon: RGB(hex: 0x3e5090)
    ),
    // Civil twilight / blue hour start (-6)
    SkyKeyframe(
      altitude: -6,
      top: RGB(hex: 0x1a2870),
      mid: RGB(hex: 0x304088),
      horizon: RGB(hex: 0x5060a8)
    ),
    // Blue hour mid
    SkyKeyframe(
      altitude: -5,
      top: RGB(hex: 0x1e3078),
      mid: RGB(hex: 0x384890),
      horizon: RGB(hex: 0x6070b8)
    ),
    // Blue hour end / golden hour start (-4)
    SkyKeyframe(
      altitude: -4,
      top: RGB(hex: 0x223880),
      mid: RGB(hex: 0x485898),
      horizon: RGB(hex: 0x7888c0)
    ),
    // Golden hour early
    SkyKeyframe(
      altitude: -2,
      top: RGB(hex: 0x2e4488),
      mid: RGB(hex: 0x6878a0),
      horizon: RGB(hex: 0xb89888)
    ),
    // Near sunrise/sunset (-0.833)
    SkyKeyframe(
      altitude: -0.833,
      top: RGB(hex: 0x385090),
      mid: RGB(hex: 0x8090a8),
      horizon: RGB(hex: 0xd89878)
    ),
    // Sun at horizon
    SkyKeyframe(
      altitude: 0,
      top: RGB(hex: 0x405898),
      mid: RGB(hex: 0x90a0b0),
      horizon: RGB(hex: 0xe8a070)
    ),
    // Low golden hour
    SkyKeyframe(
      altitude: 2,
      top: RGB(hex: 0x4870a8),
      mid: RGB(hex: 0xa8b0c0),
      horizon: RGB(hex: 0xf0b888)
    ),
    // Golden hour
    SkyKeyframe(
      altitude: 4,
      top: RGB(hex: 0x5880b0),
      mid: RGB(hex: 0xb8c0d0),
      horizon: RGB(hex: 0xe8c8a0)
    ),
    // Golden hour end
    SkyKeyframe(
      altitude: 6,
      top: RGB(hex: 0x6890b8),
      mid: RGB(hex: 0xc0c8d8),
      horizon: RGB(hex: 0xe0d0b8)
    ),
    // Early day
    SkyKeyframe(
      altitude: 10,
      top: RGB(hex: 0x70a0c8),
      mid: RGB(hex: 0xc8d4e4),
      horizon: RGB(hex: 0xd8dce0)
    ),
    // Mid-morning
    SkyKeyframe(
      altitude: 20,
      top: RGB(hex: 0x78acd0),
      mid: RGB(hex: 0xd0dced),
      horizon: RGB(hex: 0xd8e0e8)
    ),
    // Day
    SkyKeyframe(
      altitude: 35,
      top: RGB(hex: 0x80b4d8),
      mid: RGB(hex: 0xd4e2f2),
      horizon: RGB(hex: 0xdce4ec)
    ),
    // High day
    SkyKeyframe(
      altitude: 55,
      top: RGB(hex: 0x88bce0),
      mid: RGB(hex: 0xd8e8f8),
      horizon: RGB(hex: 0xdee8f0)
    ),
    // Solar noon
    SkyKeyframe(
      altitude: 90,
      top: RGB(hex: 0x90c4e8),
      mid: RGB(hex: 0xe0f0ff),
      horizon: RGB(hex: 0xe0f0f8)
    )
  ]
  // swiftlint:enable function_body_length
}
