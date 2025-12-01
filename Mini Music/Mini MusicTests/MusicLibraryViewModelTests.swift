import MusicKit
import Testing
@testable import Mini_Music

@MainActor
struct MusicLibraryViewModelTests {

    @Test func startLoadsTracksWhenAuthorized() async throws {
        let tracks = [
            TrackSummary(id: "track-1", title: "Test One", artist: "Artist"),
            TrackSummary(id: "track-2", title: "Test Two", artist: "Artist")
        ]
        let client = MusicLibraryClient(
            authorizationStatus: { .authorized },
            requestAuthorization: { .authorized },
            fetchLibrary: { _ in .init(tracks: tracks, songs: []) }
        )
        let viewModel = MusicLibraryViewModel(client: client)

        await viewModel.start()

        #expect(viewModel.state == .loaded)
        #expect(viewModel.tracks == tracks)
    }

    @Test func deniedAuthorizationSetsUnauthorized() async throws {
        let client = MusicLibraryClient(
            authorizationStatus: { .denied },
            requestAuthorization: { .denied },
            fetchLibrary: { _ in await .empty }
        )
        let viewModel = MusicLibraryViewModel(client: client)

        await viewModel.start()

        #expect(viewModel.state == .unauthorized)
    }

    @Test func loadFailureSurfacesError() async throws {
        struct TestError: Error {}
        let client = MusicLibraryClient(
            authorizationStatus: { .authorized },
            requestAuthorization: { .authorized },
            fetchLibrary: { _ in throw TestError() }
        )
        let viewModel = MusicLibraryViewModel(client: client)

        await viewModel.start()

        if case .failed(let message) = viewModel.state {
            #expect(message.contains("TestError"))
        } else {
            Issue.record("Expected failed state")
        }
    }
}
