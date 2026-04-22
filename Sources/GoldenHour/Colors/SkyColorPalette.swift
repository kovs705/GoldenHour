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
      top: RGB(hex: 0x030312),
      mid: RGB(hex: 0x09071d),
      horizon: RGB(hex: 0x120b2f)
    ),
    // Night
    SkyKeyframe(
      altitude: -18,
      top: RGB(hex: 0x070b24),
      mid: RGB(hex: 0x14133a),
      horizon: RGB(hex: 0x241c58)
    ),
    // Astronomical twilight begins to pick up violet near the horizon.
    SkyKeyframe(
      altitude: -16,
      top: RGB(hex: 0x0b1030),
      mid: RGB(hex: 0x1b1944),
      horizon: RGB(hex: 0x32246c)
    ),
    SkyKeyframe(
      altitude: -15,
      top: RGB(hex: 0x0e1438),
      mid: RGB(hex: 0x1f1d50),
      horizon: RGB(hex: 0x3d2a78)
    ),
    // Nautical twilight start
    SkyKeyframe(
      altitude: -13,
      top: RGB(hex: 0x111742),
      mid: RGB(hex: 0x23255a),
      horizon: RGB(hex: 0x49318a)
    ),
    SkyKeyframe(
      altitude: -12,
      top: RGB(hex: 0x131a48),
      mid: RGB(hex: 0x282966),
      horizon: RGB(hex: 0x58359a)
    ),
    // Nautical twilight mid
    SkyKeyframe(
      altitude: -10,
      top: RGB(hex: 0x17205b),
      mid: RGB(hex: 0x343074),
      horizon: RGB(hex: 0x6a3aa4)
    ),
    SkyKeyframe(
      altitude: -9,
      top: RGB(hex: 0x192467),
      mid: RGB(hex: 0x3b3580),
      horizon: RGB(hex: 0x7b42ae)
    ),
    SkyKeyframe(
      altitude: -8,
      top: RGB(hex: 0x1b286f),
      mid: RGB(hex: 0x43388d),
      horizon: RGB(hex: 0x8f4ab4)
    ),
    // Civil twilight / blue hour start (-6)
    SkyKeyframe(
      altitude: -6,
      top: RGB(hex: 0x203588),
      mid: RGB(hex: 0x5345a1),
      horizon: RGB(hex: 0xb05ebf)
    ),
    // Blue hour mid
    SkyKeyframe(
      altitude: -5,
      top: RGB(hex: 0x25419a),
      mid: RGB(hex: 0x6453b0),
      horizon: RGB(hex: 0xc975c9)
    ),
    // Blue hour end / golden hour start (-4)
    SkyKeyframe(
      altitude: -4,
      top: RGB(hex: 0x2b4cac),
      mid: RGB(hex: 0x7b64bb),
      horizon: RGB(hex: 0xe08dc5)
    ),
    SkyKeyframe(
      altitude: -3,
      top: RGB(hex: 0x3158b6),
      mid: RGB(hex: 0x946fc1),
      horizon: RGB(hex: 0xf18a9d)
    ),
    // Golden hour early
    SkyKeyframe(
      altitude: -2,
      top: RGB(hex: 0x3a64bf),
      mid: RGB(hex: 0xb07ac4),
      horizon: RGB(hex: 0xfb936f)
    ),
    SkyKeyframe(
      altitude: -1.2,
      top: RGB(hex: 0x4670c8),
      mid: RGB(hex: 0xc98bc4),
      horizon: RGB(hex: 0xff9f57)
    ),
    // Near sunrise/sunset (-0.833)
    SkyKeyframe(
      altitude: -0.833,
      top: RGB(hex: 0x527cd0),
      mid: RGB(hex: 0xd99ac0),
      horizon: RGB(hex: 0xffa651)
    ),
    // Sun at horizon
    SkyKeyframe(
      altitude: 0,
      top: RGB(hex: 0x5f89d7),
      mid: RGB(hex: 0xe5a7bc),
      horizon: RGB(hex: 0xffad4d)
    ),
    SkyKeyframe(
      altitude: 1,
      top: RGB(hex: 0x6d95dd),
      mid: RGB(hex: 0xedb5b8),
      horizon: RGB(hex: 0xffbc66)
    ),
    // Low golden hour
    SkyKeyframe(
      altitude: 2,
      top: RGB(hex: 0x7ea2e3),
      mid: RGB(hex: 0xf4c3b7),
      horizon: RGB(hex: 0xffc982)
    ),
    SkyKeyframe(
      altitude: 3,
      top: RGB(hex: 0x8eade7),
      mid: RGB(hex: 0xf7d2c0),
      horizon: RGB(hex: 0xffd59a)
    ),
    // Golden hour
    SkyKeyframe(
      altitude: 4,
      top: RGB(hex: 0x9db8eb),
      mid: RGB(hex: 0xf5decf),
      horizon: RGB(hex: 0xffdfb4)
    ),
    SkyKeyframe(
      altitude: 5,
      top: RGB(hex: 0xabc2ee),
      mid: RGB(hex: 0xf0e6db),
      horizon: RGB(hex: 0xffe7c8)
    ),
    // Golden hour end
    SkyKeyframe(
      altitude: 6,
      top: RGB(hex: 0xadd0f2),
      mid: RGB(hex: 0xe9edf0),
      horizon: RGB(hex: 0xfcead8)
    ),
    SkyKeyframe(
      altitude: 8,
      top: RGB(hex: 0x98c8ef),
      mid: RGB(hex: 0xdff0f9),
      horizon: RGB(hex: 0xf0efe8)
    ),
    // Early day
    SkyKeyframe(
      altitude: 10,
      top: RGB(hex: 0x88c0ec),
      mid: RGB(hex: 0xd8ebf7),
      horizon: RGB(hex: 0xe8eef3)
    ),
    SkyKeyframe(
      altitude: 12,
      top: RGB(hex: 0x7ab8ea),
      mid: RGB(hex: 0xcfe7f5),
      horizon: RGB(hex: 0xe5edf3)
    ),
    // Mid-morning
    SkyKeyframe(
      altitude: 20,
      top: RGB(hex: 0x63ace4),
      mid: RGB(hex: 0xc4e0f2),
      horizon: RGB(hex: 0xddeaf2)
    ),
    // Day
    SkyKeyframe(
      altitude: 35,
      top: RGB(hex: 0x57a5e1),
      mid: RGB(hex: 0xc2def2),
      horizon: RGB(hex: 0xdbedf7)
    ),
    // High day
    SkyKeyframe(
      altitude: 55,
      top: RGB(hex: 0x6fb5e8),
      mid: RGB(hex: 0xd1e8f8),
      horizon: RGB(hex: 0xe4f1f8)
    ),
    // Solar noon
    SkyKeyframe(
      altitude: 90,
      top: RGB(hex: 0x88c8f2),
      mid: RGB(hex: 0xe4f5ff),
      horizon: RGB(hex: 0xeaf8ff)
    )
  ]
  // swiftlint:enable function_body_length
}
