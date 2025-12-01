//
//  MiniPlayerView.swift
//  Mini Music
//
//  Created by OpenAI on 11/29/25.
//

import SwiftUI
import MusicKit

struct MiniPlayerView: View {
    let track: TrackSummary
    let isPlaying: Bool
    let namespace: Namespace.ID
    let onExpand: () -> Void
    let onTogglePlayback: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            artwork
            VStack(alignment: .leading, spacing: 2) {
                Text(track.title)
                    .font(.headline)
                    .foregroundStyle(primaryTextColor)
                    .lineLimit(1)
                Text(track.artist)
                    .font(.subheadline)
                    .foregroundStyle(secondaryTextColor)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onTogglePlayback) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(primaryTextColor)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(buttonBackgroundColor))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isPlaying ? "Pause" : "Play")

            Button(action: onExpand) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 16, weight: .semibold))
                    .padding(12)
                    .foregroundStyle(secondaryTextColor)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Expand player")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(backgroundFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08))
                )
        )
        .shadow(color: backgroundShadowColor, radius: 8, y: 4)
        .onTapGesture(perform: onExpand)
        .accessibilityIdentifier("miniPlayer")
    }

    private var artwork: some View {
        ArtworkView(track: track, preferredSize: 56)
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .matchedGeometryEffect(id: artworkID, in: namespace)
    }

    private var artworkID: String {
        "player-artwork-\(track.id)"
    }

    private var backgroundFill: AnyShapeStyle {
        if let colors = track.artworkGradientColors {
            return AnyShapeStyle(
                LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        }
        return AnyShapeStyle(.ultraThinMaterial)
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
        return track.artworkBackgroundColor?.opacity(0.9) ?? Color(.systemBackground).opacity(0.9)
    }

    private var backgroundShadowColor: Color {
        (track.artworkBackgroundColor ?? Color.black).opacity(0.25)
    }
}
