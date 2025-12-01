import SwiftUI
import MusicKit

extension TrackSummary.ArtworkPalette.Components {
    func color(adjustedBy amount: Double = 0) -> Color {
        Color(
            red: (red + amount).clamped01,
            green: (green + amount).clamped01,
            blue: (blue + amount).clamped01,
            opacity: alpha.clamped01
        )
    }

    var luminance: Double {
        0.2126 * red + 0.7152 * green + 0.0722 * blue
    }
}

extension Double {
    fileprivate var clamped01: Double { min(max(self, 0), 1) }
}

extension TrackSummary {
    var artworkBackgroundColor: Color? {
        artworkPalette?.background.color()
    }

    var artworkHighlightColor: Color? {
        artworkPalette?.background.color(adjustedBy: 0.08)
    }

    var artworkPrimaryTextColor: Color? {
        artworkPalette?.primaryText?.color()
    }

    var artworkSecondaryTextColor: Color? {
        artworkPalette?.secondaryText?.color()
    }

    var artworkGradientColors: [Color]? {
        guard let palette = artworkPalette else { return nil }
        return [palette.background.color(adjustedBy: 0.12), palette.background.color(adjustedBy: -0.05)]
    }

    var prefersLightContent: Bool {
        guard let luminance = artworkPalette?.background.luminance else { return false }
        return luminance < 0.45
    }
}
