//
//  MusicLibraryViewModel.swift
//  Mini Music
//
//  Created by Dhananjay Suresh on 10/5/25.
//

import Foundation
import Combine
import MusicKit

@MainActor
final class MusicLibraryViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case authorizing
        case unauthorized
        case loading
        case loaded
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var tracks: [TrackSummary] = []

    private let limit = 200
    private let client: MusicLibraryClient
    private var playbackSongs: [Song] = []
    private var songLookup: [TrackSummary.ID: Song] = [:]

    init(client: MusicLibraryClient) {
        self.client = client
    }
    
    convenience init() {
        self.init(client: .live)
    }

    // Entry point to ensure authorization and load content
    func start() async {
        let status = client.authorizationStatus()
        switch status {
        case .authorized:
            await loadSongs()
        case .notDetermined:
            await requestAuthorization()
        case .denied, .restricted:
            state = .unauthorized
        @unknown default:
            state = .unauthorized
        }
    }

    func requestAuthorization() async {
        state = .authorizing
        let status = await client.requestAuthorization()
        switch status {
        case .authorized:
            await loadSongs()
        case .denied, .restricted, .notDetermined:
            state = .unauthorized
        @unknown default:
            state = .unauthorized
        }
    }

    func reload() async {
        await loadSongs()
    }

    func song(for trackID: TrackSummary.ID) -> Song? {
        songLookup[trackID]
    }

    func playbackQueue() -> [Song] {
        playbackSongs
    }

    private func loadSongs() async {
        state = .loading
        do {
            let payload = try await client.fetchLibrary(limit)
            self.tracks = payload.tracks
            self.playbackSongs = payload.songs
            self.songLookup = Dictionary(uniqueKeysWithValues: payload.songs.map { ($0.id.rawValue, $0) })
            self.state = .loaded
        } catch {
            self.state = .failed(error.localizedDescription)
        }
    }
}

