//
//  SkyGradientTests.swift
//  GoldenHour
//
//  Created by Eugene Kovs on 07.04.2026.
//  https://github.com/kovs705
//

import XCTest
@testable import GoldenHour

final class SkyGradientTests: XCTestCase {

  func testGradientProduces32Stops() {
    let colors = GradientMapper.gradient(forAltitude: 0.0)
    XCTAssertEqual(colors.count, 32)
  }

  func testGradientForDifferentAltitudes() {
    let nightColors = GradientMapper.gradient(forAltitude: -25.0)
    let dayColors = GradientMapper.gradient(forAltitude: 45.0)
    let goldenColors = GradientMapper.gradient(forAltitude: 0.0)

    // All should produce 32 stops
    XCTAssertEqual(nightColors.count, 32)
    XCTAssertEqual(dayColors.count, 32)
    XCTAssertEqual(goldenColors.count, 32)

    // Night should be darker than day (compare first stop — zenith color)
    let nightBrightness = nightColors[0].r + nightColors[0].g + nightColors[0].b
    let dayBrightness = dayColors[0].r + dayColors[0].g + dayColors[0].b
    XCTAssertTrue(
      nightBrightness < dayBrightness,
      "Night sky should be darker than day sky"
    )
  }

  func testGradientColorsClamped() {
    // Test extreme altitudes don't produce out-of-range values
    for altitude in stride(from: -90.0, through: 90.0, by: 10.0) {
      let colors = GradientMapper.gradient(forAltitude: altitude)
      for (i, color) in colors.enumerated() {
        XCTAssertTrue(
          color.r >= 0 && color.r <= 1,
          "Red out of range at altitude \(altitude), stop \(i)"
        )
        XCTAssertTrue(
          color.g >= 0 && color.g <= 1,
          "Green out of range at altitude \(altitude), stop \(i)"
        )
        XCTAssertTrue(
          color.b >= 0 && color.b <= 1,
          "Blue out of range at altitude \(altitude), stop \(i)"
        )
      }
    }
  }

  func testKeyframeInterpolation() {
    // At an exact keyframe altitude, should return that keyframe's colors
    let (top, _, _) = GradientMapper.interpolatedKeyframe(forAltitude: -90.0)
    XCTAssertEqual(top.r, RGB(hex: 0x050516).r, accuracy: 0.01)
    XCTAssertEqual(top.g, RGB(hex: 0x050516).g, accuracy: 0.01)
    XCTAssertEqual(top.b, RGB(hex: 0x050516).b, accuracy: 0.01)
  }

  func testGradientSmoothTransition() {
    // Adjacent altitudes should produce similar colors (no abrupt jumps)
    let colors1 = GradientMapper.gradient(forAltitude: 0.0)
    let colors2 = GradientMapper.gradient(forAltitude: 0.5)

    for i in 0 ..< colors1.count {
      let diff = abs(colors1[i].r - colors2[i].r)
        + abs(colors1[i].g - colors2[i].g)
        + abs(colors1[i].b - colors2[i].b)
      XCTAssertTrue(
        diff < 0.2,
        "Color jump too large between adjacent altitudes at stop \(i): diff=\(diff)"
      )
    }
  }
}
