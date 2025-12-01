//
//  TrackSummary.swift
//  Mini Music
//
//  Created by OpenAI on 2/14/25.
//

import Foundation
import MusicKit
import CoreGraphics

struct TrackSummary: Identifiable, Equatable, Sendable {
    typealias ID = String

    let id: ID
    let title: String
    let artist: String
    let artwork: Artwork?
    let artworkURL: URL?
    let artworkPalette: ArtworkPalette?

    @MainActor init(id: ID, title: String, artist: String, artwork: Artwork? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artwork = artwork
        self.artworkURL = artwork?.url(width: 600, height: 600)
        self.artworkPalette = artwork.flatMap(ArtworkPalette.init)
    }

    @MainActor init(song: Song) {
        self.init(id: song.id.rawValue, title: song.title, artist: song.artistName, artwork: song.artwork)
    }
}

extension TrackSummary {
    static func == (lhs: TrackSummary, rhs: TrackSummary) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.artist == rhs.artist &&
        lhs.artworkURL == rhs.artworkURL
    }
}

extension TrackSummary {
    var accessibilityIdentifier: String { "track-\(id)" }
}

#if DEBUG
extension TrackSummary {
    @MainActor static func mock(
        id: ID = UUID().uuidString,
        title: String = "Sample Song",
        artist: String = "Sample Artist",
        artwork: Artwork? = nil
    ) -> TrackSummary {
        TrackSummary(id: id, title: title, artist: artist, artwork: artwork)
    }
}
#endif

extension TrackSummary {
    struct ArtworkPalette: Equatable, Sendable {
        struct Components: Equatable, Sendable {
            let red: Double
            let green: Double
            let blue: Double
            let alpha: Double
        }

        let background: Components
        let primaryText: Components?
        let secondaryText: Components?

        @MainActor init?(artwork: Artwork) {
            guard let backgroundColor = artwork.backgroundColor?.normalizedComponents else { return nil }
            self.background = backgroundColor
            self.primaryText = artwork.primaryTextColor?.normalizedComponents
            self.secondaryText = artwork.secondaryTextColor?.normalizedComponents
        }
    }
}

private extension CGColor {
    var normalizedComponents: TrackSummary.ArtworkPalette.Components? {
        guard let sRGB = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
        guard let converted = self.converted(to: sRGB, intent: .defaultIntent, options: nil) else { return nil }
        guard let comps = converted.components else { return nil }
        let red = Double(comps[safe: 0] ?? 0)
        let green = Double(comps[safe: 1] ?? red)
        let blue = Double(comps[safe: 2] ?? red)
        let alpha = Double(comps[safe: 3] ?? 1)
        return .init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

private extension Array where Element == CGFloat {
    subscript(safe index: Int) -> CGFloat? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
