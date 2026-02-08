import Testing
import Foundation
@testable import YT_Vapor_iOS_App

/// Tests for SongsListViewModel
@Suite("SongsListViewModel Tests")
struct SongsListViewModelTests {

    @Test("Initial state is idle")
    @MainActor
    func testInitialStateIsIdle() {
        let viewModel = makeViewModel()

        if case .idle = viewModel.state {
            // Success
        } else {
            Issue.record("Expected initial state to be idle")
        }
    }

    @Test("Loading songs successfully updates state to loaded")
    @MainActor
    func testLoadSongsSuccessfully() async {
        let mockSongs = [
            Song(id: UUID(), title: "Song 1", artist: "Artist 1"),
            Song(id: UUID(), title: "Song 2", artist: "Artist 2")
        ]
        let viewModel = makeViewModel(songs: mockSongs)

        await viewModel.loadSongs()

        if case .loaded(let songs) = viewModel.state {
            #expect(songs.count == 2)
            #expect(songs[0].title == "Song 1")
            #expect(songs[1].title == "Song 2")
        } else {
            Issue.record("Expected state to be loaded with songs")
        }
    }

    @Test("Loading songs with error updates state to error")
    @MainActor
    func testLoadSongsWithError() async {
        let expectedError = NetworkError.noData
        let viewModel = makeViewModel(error: expectedError)

        await viewModel.loadSongs()

        if case .error(let error) = viewModel.state {
            #expect(error as? NetworkError == expectedError)
        } else {
            Issue.record("Expected state to be error")
        }
    }

    @Test("State changes from idle to loading to loaded")
    @MainActor
    func testStateTransitions() async {
        let viewModel = makeViewModel(songs: [Song(id: UUID(), title: "Test", artist: "Artist")])

        if case .idle = viewModel.state {
            // Expected
        } else {
            Issue.record("Expected initial state to be idle")
        }

        await viewModel.loadSongs()

        if case .loaded = viewModel.state {
            // Expected
        } else {
            Issue.record("Expected final state to be loaded")
        }
    }

    @Test("Loading empty songs list returns loaded state with empty array")
    @MainActor
    func testLoadEmptySongsList() async {
        let viewModel = makeViewModel()

        await viewModel.loadSongs()

        if case .loaded(let songs) = viewModel.state {
            #expect(songs.isEmpty)
        } else {
            Issue.record("Expected state to be loaded with empty array")
        }
    }

    @Test("Navigating to add song triggers router")
    @MainActor
    func testNavigateToAddSong() {
        let mockRouter = MockSongsListRouter()
        let viewModel = makeViewModel(router: mockRouter)

        viewModel.navigateToAddSong()

        #expect(mockRouter.navigateToAddSongCalled)
    }
}

// MARK: - Helper Functions

@MainActor
private func makeViewModel(
    songs: [Song] = [],
    error: Error? = nil,
    router: MockSongsListRouter = MockSongsListRouter()
) -> SongsListViewModel {
    let getSongsUseCase = error != nil
        ? MockGetSongsUseCase(throwing: error!)
        : MockGetSongsUseCase(returning: songs)
    let deleteSongUseCase = MockDeleteSongUseCase()
    let container = AppDependencyContainer()
    let addSongBuilder = AddSongBuilder(
        container: container,
        songsListRouter: router,
        onSongAdded: {}
    )
    return SongsListViewModel(
        getSongsUseCase: getSongsUseCase,
        deleteSongUseCase: deleteSongUseCase,
        router: router,
        addSongBuilder: addSongBuilder,
        container: container
    )
}

// MARK: - Mock Router

final class MockSongsListRouter: SongsListRouterProtocol {
    var navigateToAddSongCalled = false
    var navigateToEditSongCalled = false
    var dismissCalled = false

    func navigateToAddSong(builder: AddSongBuilder) {
        navigateToAddSongCalled = true
    }

    func navigateToEditSong(builder: EditSongBuilder) {
        navigateToEditSongCalled = true
    }

    func dismiss() {
        dismissCalled = true
    }
}
