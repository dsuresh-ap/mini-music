//
//  ContentView.swift
//  Mini Music
//
//  Created by Dhananjay Suresh on 10/5/25.
//

import SwiftUI
import MusicKit

struct ContentView: View {
    @StateObject private var viewModel: MusicLibraryViewModel
    private let playbackController: MusicPlaybackControlling

    @ObservedObject private var playerState = SystemMusicPlayer.shared.state
    @Namespace private var playerNamespace

    @State private var isStartingPlayback = false
    @State private var startingTrackID: TrackSummary.ID? = nil
    @State private var nowPlayingTrack: TrackSummary?
    @State private var isPlayerExpanded = false
    @State private var playerDragOffset: CGFloat = 0
    @State private var queueObservationTask: Task<Void, Never>?

    init(
        viewModel: @autoclosure @escaping () -> MusicLibraryViewModel = ContentView.makeDefaultViewModel(),
        playbackController: MusicPlaybackControlling = ContentView.makeDefaultPlaybackController()
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.playbackController = playbackController
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .authorizing, .loading:
                    ProgressView("Loading your library…")
                case .unauthorized:
                    authorizationPrompt
                case .loaded:
                    if viewModel.tracks.isEmpty {
                        emptyLibrary
                    } else {
                        trackGrid
                    }
                case .failed(let message):
                    failureView(message)
                }
            }
            .navigationTitle("My Songs")
        }
        .safeAreaInset(edge: .bottom, spacing: 0) { miniPlayerInset }
        .overlay(playerOverlay)
        .onReceive(playerState.objectWillChange) { _ in
            syncNowPlayingTrackFromQueue()
        }
        .onAppear { startObservingSystemPlayerQueue() }
        .onDisappear { stopObservingSystemPlayerQueue() }
        .task {
            await viewModel.start()
            syncNowPlayingTrackFromQueue()
        }
    }
}

// MARK: - Subviews

private extension ContentView {
    var authorizationPrompt: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note.list")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("We need access to your Apple Music library")
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("Grant access to fetch your songs.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Grant Access") {
                Task { await viewModel.requestAuthorization() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    var emptyLibrary: some View {
        ContentUnavailableView(
            "No Songs",
            systemImage: "music.note",
            description: Text("Your library appears to be empty.")
        )
    }

    func failureView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)
            Text("Failed to load songs")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Try Again") {
                Task { await viewModel.start() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    var trackGrid: some View {
        ScrollView {
            let columns = [GridItem(.adaptive(minimum: 140), spacing: 16)]
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.tracks, id: \.id) { track in
                    Button {
                        handleSelection(of: track)
                    } label: {
                        SongItemView(track: track, isStartingPlayback: isStartingPlayback && startingTrackID == track.id)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier(track.accessibilityIdentifier)
                    .disabled(isStartingPlayback && startingTrackID == track.id)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .refreshable { await viewModel.reload() }
    }
}

// MARK: - Player Handling

private extension ContentView {
    func handleSelection(of track: TrackSummary) {
        guard !isStartingPlayback else { return }
        isStartingPlayback = true
        startingTrackID = track.id
        PlatformHaptics.selection()

        Task {
            defer {
                isStartingPlayback = false
                startingTrackID = nil
            }

            let queue = viewModel.playbackQueue()
            guard let song = viewModel.song(for: track.id), !queue.isEmpty else {
                await MainActor.run { presentPlayer(for: track) }
                return
            }

            do {
                try await playbackController.startPlayback(queue: queue, startingAt: song)
                await MainActor.run {
                    presentPlayer(for: track)
                    syncNowPlayingTrackFromQueue()
                }
            } catch {
                PlatformHaptics.error()
                print("Failed to start playback: \(error)")
            }
        }
    }

    @MainActor
    func presentPlayer(for track: TrackSummary) {
        nowPlayingTrack = track
        isPlayerExpanded = true
        playerDragOffset = 0
    }

    func collapsePlayer() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
            isPlayerExpanded = false
            playerDragOffset = 0
        }
    }

    func togglePlayback() {
        Task {
            let player = SystemMusicPlayer.shared
            do {
                switch player.state.playbackStatus {
                case .playing, .seekingBackward, .seekingForward:
                    player.pause()
                default:
                    try await player.play()
                }
            } catch {
                print("Failed to toggle playback: \(error)")
            }
        }
    }
}

// MARK: - Mini Player & Overlay

private extension ContentView {
    var miniPlayerInset: some View {
        Group {
            if let track = nowPlayingTrack, !isPlayerExpanded {
                MiniPlayerView(
                    track: track,
                    isPlaying: isPlaying,
                    namespace: playerNamespace,
                    onExpand: expandPlayer,
                    onTogglePlayback: togglePlayback
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: nowPlayingTrack?.id)
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: isPlayerExpanded)
    }

    var playerOverlay: some View {
        Group {
            if let track = nowPlayingTrack, isPlayerExpanded {
                ZStack {
                    Color.black.opacity(scrimOpacity)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture { collapsePlayer() }

                    FullScreenPlayerView(
                        track: track,
                        isPlaying: isPlaying,
                        namespace: playerNamespace,
                        onClose: collapsePlayer,
                        onTogglePlayback: togglePlayback
                    )
                    .id(track.id)
                    .offset(y: playerDragOffset)
                    .gesture(playerDragGesture)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.9), value: isPlayerExpanded)
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: playerDragOffset)
            }
        }
    }

    func expandPlayer() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
            isPlayerExpanded = true
            playerDragOffset = 0
        }
    }

    var playerDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = value.translation.height
                if translation >= 0 {
                    playerDragOffset = translation
                }
            }
            .onEnded { value in
                let translation = value.translation.height
                let shouldDismiss = translation > 140
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    playerDragOffset = 0
                }
                if shouldDismiss {
                    collapsePlayer()
                }
            }
    }

    var scrimOpacity: Double {
        guard isPlayerExpanded else { return 0 }
        let normalized = min(max(Double(playerDragOffset / 300), 0), 1)
        return (1 - normalized) * 0.35
    }
}

// MARK: - Helpers

private extension ContentView {
    func syncNowPlayingTrackFromQueue() {
        guard case .song(let song)? = SystemMusicPlayer.shared.queue.currentEntry?.item else {
            return
        }

        if let librarySong = viewModel.song(for: song.id.rawValue) {
            applyNowPlayingSummary(TrackSummary(song: librarySong))
        } else {
            applyNowPlayingSummary(TrackSummary(song: song))
        }
    }

    func startObservingSystemPlayerQueue() {
        guard queueObservationTask == nil else { return }
        queueObservationTask = Task {
            let entry = SystemMusicPlayer.shared.queue.currentEntry
            if case .song(let song)? = entry?.item {
                if let librarySong = viewModel.song(for: song.id.rawValue) {
                    await MainActor.run {
                        applyNowPlayingSummary(TrackSummary(song: librarySong))
                    }
                } else {
                    await MainActor.run {
                        applyNowPlayingSummary(TrackSummary(song: song))
                    }
                }
            }
        }
    }

    func stopObservingSystemPlayerQueue() {
        queueObservationTask?.cancel()
        queueObservationTask = nil
    }

    @MainActor
    func applyNowPlayingSummary(_ summary: TrackSummary) {
        if nowPlayingTrack?.id != summary.id {
            nowPlayingTrack = summary
        } else if nowPlayingTrack?.artworkURL != summary.artworkURL {
            nowPlayingTrack = summary
        }
    }

    var isPlaying: Bool {
        switch playerState.playbackStatus {
        case .playing, .seekingBackward, .seekingForward:
            return true
        default:
            return false
        }
    }
}

// MARK: - Factories

extension ContentView {
    private static func makeDefaultViewModel() -> MusicLibraryViewModel {
        if ProcessInfo.processInfo.arguments.contains("--uitest-fixtures") {
            return MusicLibraryViewModel(client: .fixtures)
        }
        return MusicLibraryViewModel()
    }

    private static func makeDefaultPlaybackController() -> MusicPlaybackControlling {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--uitest-fixtures") {
            return NoopPlaybackController()
        }
        #endif
        return SystemMusicPlaybackController()
    }
}

#Preview {
    ContentView()
}
