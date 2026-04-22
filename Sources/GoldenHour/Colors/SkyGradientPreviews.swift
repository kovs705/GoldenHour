//
//  SkyGradientPreviews.swift
//  GoldenHour
//
//  Created by Eugene Kovs on 21.04.2026.
//  https://github.com/kovs705
//

import SwiftUI

private struct GradientStripPreview: View {
  let title: String
  let altitude: Double

  private var colors: [Color] {
    GradientMapper.gradient(forAltitude: altitude).map(\.swiftUIColor)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text(title)
          .font(.headline)
        Spacer()
        Text(String(format: "%.1f°", altitude))
          .font(.subheadline.monospacedDigit())
          .foregroundStyle(.secondary)
      }

      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(
          LinearGradient(
            colors: colors,
            startPoint: .top,
            endPoint: .bottom
          )
        )
        .frame(height: 140)
        .overlay(alignment: .bottomLeading) {
          Text("zenith -> horizon")
            .font(.caption)
            .foregroundStyle(.white.opacity(0.8))
            .padding(12)
        }
    }
    .padding()
    .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
  }
}

private struct SkyGradientPreviewGallery: View {
  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        GradientStripPreview(title: "Night", altitude: -18)
        GradientStripPreview(title: "Blue Hour", altitude: -5)
        GradientStripPreview(title: "Sunrise / Sunset", altitude: 0)
        GradientStripPreview(title: "Golden Hour", altitude: 3)
        GradientStripPreview(title: "Day", altitude: 35)
      }
      .padding()
    }
    .background(Color.black.opacity(0.06))
  }
}

#if DEBUG
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview("Sky Gradient Gallery") {
  SkyGradientPreviewGallery()
}
#endif
