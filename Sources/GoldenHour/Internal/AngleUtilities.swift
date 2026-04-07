import Foundation

extension Double {

  /// Convert degrees to radians.
  var degreesToRadians: Double { self * .pi / 180.0 }

  /// Convert radians to degrees.
  var radiansToDegrees: Double { self * 180.0 / .pi }

  /// Normalize to range [0, 360).
  var normalizedDegrees: Double {
    var result = truncatingRemainder(dividingBy: 360.0)
    if result < 0 { result += 360.0 }
    return result
  }

  /// Normalize to range [0, 24).
  var normalizedHours: Double {
    var result = truncatingRemainder(dividingBy: 24.0)
    if result < 0 { result += 24.0 }
    return result
  }
}
