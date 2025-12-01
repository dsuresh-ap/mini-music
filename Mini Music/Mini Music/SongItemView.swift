//
//  SongItemView.swift
//  Mini Music
//
//  Created by Dhananjay Suresh on 11/9/25.
//

import SwiftUI
import MusicKit

struct SongItemView: View {
    let track: TrackSummary
    let isStartingPlayback: Bool

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                artworkView

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.headline)
                        .lineLimit(2)
                    Text(track.artist)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .accessibilityElement(children: .combine)

            if isStartingPlayback {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.black.opacity(0.25))
                    .frame(width: 140, height: 140)
                    .overlay(
                        ProgressView()
                            .tint(.white)
                    )
                    .allowsHitTesting(false)
            }
        }
    }

    private var artworkView: some View {
        ArtworkView(track: track, preferredSize: 140)
            .frame(width: 140, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
