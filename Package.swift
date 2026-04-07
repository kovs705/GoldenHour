// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "GoldenHour",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .watchOS(.v9),
    .tvOS(.v16)
  ],
  products: [
    .library(
      name: "GoldenHour",
      targets: ["GoldenHour"]
    )
  ],
  targets: [
    .target(
      name: "GoldenHour",
      dependencies: []
    ),
    .testTarget(
      name: "GoldenHourTests",
      dependencies: ["GoldenHour"]
    )
  ]
)
