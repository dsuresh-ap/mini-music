//
//  MusicLibraryClient.swift
//  Mini Music
//
//  Created by OpenAI on 2/14/25.
//

import Foundation
import MusicKit

struct MusicLibraryClient {
    struct Payload: Sendable {
        let tracks: [TrackSummary]
        let songs: [Song]

        static let empty = Payload(tracks: [], songs: [])
    }

    var authorizationStatus: @Sendable () -> MusicAuthorization.Status
    var requestAuthorization: @Sendable () async -> MusicAuthorization.Status
    var fetchLibrary: @Sendable (_ limit: Int) async throws -> Payload
}

extension MusicLibraryClient {
    static let live = MusicLibraryClient(
        authorizationStatus: { MusicAuthorization.currentStatus },
        requestAuthorization: { await MusicAuthorization.request() },
        fetchLibrary: { limit in
            var request = MusicLibraryRequest<Song>()
            request.limit = limit
            let response = try await request.response()
            let songs = Array(response.items)
            let tracks = await MainActor.run {
                songs.map(TrackSummary.init(song:))
            }
            return Payload(tracks: tracks, songs: songs)
        }
    )
}

#if DEBUG
extension MusicLibraryClient {
    static let fixtures = MusicLibraryClient(
        authorizationStatus: { .authorized },
        requestAuthorization: { .authorized },
        fetchLibrary: { _ in
            let mockTracks = await MainActor.run {
                [
                    TrackSummary.mock(id: "fixture-1", title: "Sunshine Dance", artist: "DJ Sprout"),
                    TrackSummary.mock(id: "fixture-2", title: "Rainbow Parade", artist: "Lil Beats"),
                    TrackSummary.mock(id: "fixture-3", title: "Starlight Lullaby", artist: "Dream Band")
                ]
            }
            return Payload(tracks: mockTracks, songs: [])
        }
    )
}
#endif
