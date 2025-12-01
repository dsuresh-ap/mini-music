//
//  FullScreenPlayerView.swift
//  Mini Music
//
//  Created by OpenAI on 2/14/25.
//

import SwiftUI
import MusicKit
import UIKit

struct FullScreenPlayerView: View {
    let track: TrackSummary
    let isPlaying: Bool
    let namespace: Namespace.ID?
    let onClose: () -> Void
    let onTogglePlayback: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let artworkSize = artworkSize(for: proxy.size)
            ZStack(alignment: .topTrailing) {
                backgroundGradient
                    .ignoresSafeArea()

                VStack(spacing: 28) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.35))
                        .frame(width: 48, height: 5)
                        .padding(.top, 12)

                    nowPlayingLabel

                    artwork(of: artworkSize)

                    metadataCard

                    Button(action: onTogglePlayback) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .foregroundStyle(buttonForegroundColor)
                            .frame(width: 88, height: 88)
                            .background(Circle().fill(buttonBackgroundColor))
                            .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                    }
                    .accessibilityLabel(isPlaying ? "Pause" : "Play")

                    PlatformVolumeView(
                        accentColor: volumeAccentColor,
                        textColor: secondaryTextColor,
                        backgroundColor: volumeBackgroundColor
                    )
                        .padding(.horizontal)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(secondaryTextColor)
                        .padding()
                }
                .accessibilityIdentifier("player.closeButton")
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .accessibilityIdentifier("fullScreenPlayer")
    }

    private func artwork(of size: CGFloat) -> some View {
        ArtworkView(track: track, preferredSize: size)
            .applyMatchedGeometryIfNeeded(id: matchedArtworkID, namespace: namespace, isSource: false)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: 24, y: 12)
            .padding(.horizontal, 12)
    }

    private var matchedArtworkID: String {
        "player-artwork-\(track.id)"
    }

    private func artworkSize(for availableSize: CGSize) -> CGFloat {
        let widthCap = availableSize.width - 64
        let heightCap = availableSize.height * 0.45
        let target = min(widthCap, heightCap)
        return max(min(target, 420), 260)
    }

    private var metadataCard: some View {
        VStack(spacing: 6) {
            Text(track.title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(primaryTextColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            Text(track.artist)
                .font(.headline)
                .foregroundStyle(secondaryTextColor)
                .lineLimit(1)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(metadataBackgroundColor)
        )
        .padding(.horizontal)
    }

    private var metadataBackgroundColor: Color {
        if track.prefersLightContent {
            return Color.white.opacity(0.25)
        }
        return Color(.systemBackground).opacity(0.08)
    }

    private var nowPlayingLabel: some View {
        Text("Now Playing")
            .font(.caption.smallCaps())
            .foregroundStyle(secondaryTextColor.opacity(0.8))
    }

    private var backgroundGradient: LinearGradient {
        if let colors = track.artworkGradientColors {
            return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
        }
        return LinearGradient(
            colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var primaryTextColor: Color {
        if track.prefersLightContent {
            return .black
        }
        return track.artworkPrimaryTextColor ?? .primary
    }

    private var secondaryTextColor: Color {
        if track.prefersLightContent {
            return Color.black.opacity(0.7)
        }
        return track.artworkSecondaryTextColor ?? .secondary
    }

    private var buttonBackgroundColor: Color {
        if track.prefersLightContent {
            return Color.white.opacity(0.9)
        }
        return track.artworkBackgroundColor?.opacity(0.9) ?? Color.accentColor
    }

    private var buttonForegroundColor: Color {
        if track.prefersLightContent {
            return .black
        }
        return track.artworkPrimaryTextColor ?? .white
    }

    private var volumeAccentColor: Color {
        track.artworkPrimaryTextColor ?? .accentColor
    }

    private var volumeBackgroundColor: Color {
        track.artworkBackgroundColor?.opacity(0.35) ?? Color(.secondarySystemBackground).opacity(0.8)
    }
}

private extension View {
    @ViewBuilder
    func applyMatchedGeometryIfNeeded(id: String, namespace: Namespace.ID?, isSource: Bool = true) -> some View {
        if let namespace {
            self.matchedGeometryEffect(id: id, in: namespace, isSource: isSource)
        } else {
            self
        }
    }
}
