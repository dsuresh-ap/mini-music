//
//  PlaybackController.swift
//  Mini Music
//
//  Created by OpenAI on 2/14/25.
//

import Foundation
import MusicKit

@MainActor
protocol MusicPlaybackControlling {
    func startPlayback(queue: [Song], startingAt song: Song) async throws
}

enum PlaybackControllerError: Error, LocalizedError {
    case missingQueue

    var errorDescription: String? {
        switch self {
        case .missingQueue:
            return "Playback queue is empty."
        }
    }
}

struct SystemMusicPlaybackController: MusicPlaybackControlling {
    func startPlayback(queue: [Song], startingAt song: Song) async throws {
        guard !queue.isEmpty else { throw PlaybackControllerError.missingQueue }
        let player = SystemMusicPlayer.shared
        player.queue = .init(for: queue, startingAt: song)
        try await player.play()
    }
}

#if DEBUG
struct NoopPlaybackController: MusicPlaybackControlling {
    func startPlayback(queue: [Song], startingAt song: Song) async throws { }
}
#endif
