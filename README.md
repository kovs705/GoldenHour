<div align="center">

<img width="300" height="300" src="/Assets/GoldenHour.png" alt="TokenEdittttor icon">

# GoldenHour

*Sun position, twilight phases, golden & blue hours, and sky gradient colors — from time and location.*

[![Swift](https://img.shields.io/badge/Swift-5.9+-F05138.svg?style=flat&logo=swift)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-16+-000000.svg?style=flat&logo=apple)](https://developer.apple.com/ios/)
[![macOS](https://img.shields.io/badge/macOS-13+-000000.svg?style=flat&logo=apple)](https://developer.apple.com/macos/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](LICENSE)
[![SPM](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager/)

</div>

---

## What It Does

GoldenHour computes everything you need to build sun-aware interfaces:

- **Sun event times** — astronomical / nautical / civil dawn & dusk, official sunrise & sunset, solar noon
- **Golden hour & blue hour** — morning and evening start/end pairs
- **Solar position** — altitude and azimuth at any arbitrary instant
- **Twilight phase** — classify any moment into one of 6 phases (night → day)
- **Sky gradient** — 32-color smooth gradient matching the current sky, ready for SwiftUI
- **Polar region handling** — midnight sun and polar night detected correctly

Zero dependencies. Pure Swift. `Sendable` throughout.

---

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/kovs705/GoldenHour.git", from: "1.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies** → paste the repository URL.

---

## Usage

```swift
import GoldenHour
import CoreLocation

let calculator = SolarCalculator()
let coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.006)
let timeZone = TimeZone(identifier: "America/New_York")!
```

### Sun Events

```swift
let events = calculator.events(for: Date(), at: coordinate, timeZone: timeZone)

events.sunrise          // Date? — official sunrise
events.sunset           // Date? — official sunset
events.civilDawn        // Date? — civil twilight begins
events.solarNoon        // Date? — sun at highest point

events.goldenHourMorningStart  // Date? — morning golden hour begins
events.goldenHourMorningEnd    // Date? — morning golden hour ends
events.blueHourEveningStart    // Date? — evening blue hour begins

events.isMidnightSun   // Bool — true if sun never sets
events.isPolarNight     // Bool — true if sun never rises
```

### Sun Position

```swift
let position = calculator.position(at: Date(), coordinate: coordinate)

position.altitude  // Double — degrees above horizon (negative = below)
position.azimuth   // Double — degrees clockwise from north
position.phase     // TwilightPhase — current phase
```

### Twilight Phase

```swift
let phase = calculator.phase(at: Date(), coordinate: coordinate)

switch phase {
case .night:                  // Sun < -18°
case .astronomicalTwilight:   // -18° to -12°
case .nauticalTwilight:       // -12° to -6°
case .blueHour:               // -6° to -4°
case .goldenHour:             // -4° to +6°
case .day:                    // Sun > +6°
}
```

`TwilightPhase` conforms to `Comparable` — you can write `phase >= .goldenHour`.

### Sky Gradient

```swift
let gradient = calculator.gradient(at: Date(), coordinate: coordinate)

gradient.colors        // [Color] — 32 SwiftUI colors, zenith → horizon
gradient.sunAltitude   // Double — the altitude that produced this gradient
gradient.phase         // TwilightPhase

// Drop straight into SwiftUI:
Rectangle()
  .fill(gradient.linearGradient())
  .ignoresSafeArea()
```

The gradient smoothly transitions through all phases — from deep navy night, through blue/purple twilight, warm orange golden hour, to light blue daytime.

---

## Twilight Phases

| Phase | Sun Altitude | Description |
|:------|:-------------|:------------|
| Night | below -18° | Full darkness |
| Astronomical Twilight | -18° to -12° | Faintest light on horizon |
| Nautical Twilight | -12° to -6° | Horizon line barely visible |
| Blue Hour | -6° to -4° | Deep blue sky, no direct sunlight |
| Golden Hour | -4° to +6° | Warm, soft light — best for photography |
| Day | above +6° | Full daylight |

---

## Algorithm

Event times are computed using the [Ed Williams Sunrise/Sunset Algorithm](https://edwilliams.org/sunrise_sunset_algorithm.htm), which solves for the moment the sun crosses a specific zenith angle.

Sun position at arbitrary times uses NOAA General Solar Position formulas — fractional year, equation of time, solar declination, hour angle, and zenith/azimuth geometry.

Key design decisions:
- **All math in UTC** — local conversion only at the output boundary
- **Explicit `TimeZone` parameter** — avoids device-timezone mismatch bugs
- **Phase from altitude, not event times** — polar regions work automatically
- **Day-boundary resolution** — handles longitude wrapping across UTC midnight

---

## Requirements

| | Minimum |
|:--|:--------|
| Swift | 5.9+ |
| iOS | 16.0+ |
| macOS | 13.0+ |
| watchOS | 9.0+ |
| tvOS | 16.0+ |
| Dependencies | None |

---

## Alternative

[**Solar**](https://github.com/ceeK/Solar) by ceeK is an existing Swift library for sunrise/sunset calculations. It's a solid starting point, but has several open issues:

- Timezone mismatch when device timezone differs from coordinate timezone ([#61](https://github.com/ceeK/Solar/issues/61))
- Incorrect `isDaytime` for polar regions / midnight sun ([#59](https://github.com/ceeK/Solar/issues/59))
- Sunrise/sunset dates off by 1 day ([#40](https://github.com/ceeK/Solar/issues/40))
- DST handling issues ([#36](https://github.com/ceeK/Solar/issues/36))

GoldenHour addresses all of these, and adds golden/blue hour times, sun position at arbitrary instants, phase detection, and sky gradient colors.

---

## License

MIT

---

<div align="center">

Made for devs with 🌅

</div>
