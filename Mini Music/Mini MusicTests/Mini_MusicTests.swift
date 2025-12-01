//
//  Mini_MusicTests.swift
//  Mini MusicTests
//
//  Created by Dhananjay Suresh on 10/5/25.
//

import Testing
@testable import Mini_Music

struct Mini_MusicTests {

    @Test func trackSummaryExposesStableAccessibilityIdentifier() async throws {
        let track = TrackSummary(id: "abc123", title: "Sample", artist: "Artist")
        #expect(track.accessibilityIdentifier == "track-abc123")
    }

    @Test func musicLibraryClientEmptyPayloadIsStatelessSingleton() async throws {
        let empty = MusicLibraryClient.Payload.empty
        #expect(empty.tracks.isEmpty)
        #expect(empty.songs.isEmpty)
    }
}
