//
//  SkyGradient.swift
//  GoldenHour
//
//  Created by Eugene Kovs on 07.04.2026.
//  https://github.com/kovs705
//

import SwiftUI

/// A sky gradient representing the colors of the sky for a given sun position.
/// Colors are ordered from the top of the sky (zenith) to the horizon.
public struct SkyGradient: Sendable {

  /// Ordered array of colors forming the gradient, from zenith to horizon.
  /// Contains 32 colors for smooth transitions.
  public let colors: [Color]

  /// The sun altitude (in degrees) that produced this gradient.
  public let sunAltitude: Double

  /// The twilight phase corresponding to this gradient.
  public let phase: TwilightPhase

  /// Create a SwiftUI LinearGradient suitable for a full-screen sky background.
  public func linearGradient() -> LinearGradient {
    LinearGradient(
      colors: colors,
      startPoint: .top,
      endPoint: .bottom
    )
  }
}

// MARK: - Internal conversion

extension RGB {
  var swiftUIColor: Color {
    Color(red: r, green: g, blue: b)
  }
}
