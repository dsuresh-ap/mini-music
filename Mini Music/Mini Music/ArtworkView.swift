import SwiftUI
import MusicKit

struct ArtworkView: View {
    let track: TrackSummary
    let preferredSize: CGFloat

    init(track: TrackSummary, preferredSize: CGFloat = 300) {
        self.track = track
        self.preferredSize = preferredSize
    }

    var body: some View {
        ZStack {
            placeholderBackground
            content
        }
        .frame(width: preferredSize, height: preferredSize)
        .clipShape(Rectangle())
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var content: some View {
        if let artwork = track.artwork {
            ArtworkImage(artwork, width: preferredSize, height: preferredSize)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        } else if let url = track.artworkURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    placeholderOverlay
                case .failure:
                    placeholderOverlay
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                @unknown default:
                    placeholderOverlay
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        } else {
            placeholderOverlay
        }
    }

    private var placeholderBackground: Color {
        track.artworkBackgroundColor ?? Color(.tertiarySystemFill)
    }

    private var placeholderOverlay: some View {
        Image(systemName: "music.note")
            .font(.system(size: 28, weight: .medium))
            .foregroundStyle(track.artworkSecondaryTextColor ?? .secondary)
    }
}
