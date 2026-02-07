import Testing
import Foundation
@testable import YT_Vapor_iOS_App

/// Tests for SongsListViewModel
@Suite("SongsListViewModel Tests")
struct SongsListViewModelTests {

    @Test("Initial state is idle")
    @MainActor
    func testInitialStateIsIdle() {
        let mockUseCase = MockGetSongsUseCase(returning: [])
        let mockRouter = MockSongsListRouter()
        let mockBuilder = createMockAddSongBuilder()
        let viewModel = SongsListViewModel(getSongsUseCase: mockUseCase, router: mockRouter, addSongBuilder: mockBuilder)

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
        let mockUseCase = MockGetSongsUseCase(returning: mockSongs)
        let mockRouter = MockSongsListRouter()
        let mockBuilder = createMockAddSongBuilder()
        let viewModel = SongsListViewModel(getSongsUseCase: mockUseCase, router: mockRouter, addSongBuilder: mockBuilder)

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
        let mockUseCase = MockGetSongsUseCase(throwing: expectedError)
        let mockRouter = MockSongsListRouter()
        let mockBuilder = createMockAddSongBuilder()
        let viewModel = SongsListViewModel(getSongsUseCase: mockUseCase, router: mockRouter, addSongBuilder: mockBuilder)

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
        let mockSongs = [Song(id: UUID(), title: "Test", artist: "Artist")]
        let mockUseCase = MockGetSongsUseCase(returning: mockSongs)
        let mockRouter = MockSongsListRouter()
        let mockBuilder = createMockAddSongBuilder()
        let viewModel = SongsListViewModel(getSongsUseCase: mockUseCase, router: mockRouter, addSongBuilder: mockBuilder)

        // Initial state should be idle
        if case .idle = viewModel.state {
            // Expected
        } else {
            Issue.record("Expected initial state to be idle")
        }

        await viewModel.loadSongs()

        // After loading should be loaded
        if case .loaded = viewModel.state {
            // Expected
        } else {
            Issue.record("Expected final state to be loaded")
        }
    }

    @Test("Loading empty songs list returns loaded state with empty array")
    @MainActor
    func testLoadEmptySongsList() async {
        let mockUseCase = MockGetSongsUseCase(returning: [])
        let mockRouter = MockSongsListRouter()
        let mockBuilder = createMockAddSongBuilder()
        let viewModel = SongsListViewModel(getSongsUseCase: mockUseCase, router: mockRouter, addSongBuilder: mockBuilder)

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
        let mockUseCase = MockGetSongsUseCase(returning: [])
        let mockRouter = MockSongsListRouter()
        let mockBuilder = createMockAddSongBuilder()
        let viewModel = SongsListViewModel(getSongsUseCase: mockUseCase, router: mockRouter, addSongBuilder: mockBuilder)

        viewModel.navigateToAddSong()

        #expect(mockRouter.navigateToAddSongCalled)
    }
}

// MARK: - Helper Functions

@MainActor
func createMockAddSongBuilder() -> AddSongBuilder {
    return AddSongBuilder(
        container: AppDependencyContainer(),
        songsListRouter: MockSongsListRouter()
    )
}

// MARK: - Mock Router

@MainActor
final class MockSongsListRouter: SongsListRouterProtocol {
    var navigateToAddSongCalled = false
    var dismissCalled = false

    func navigateToAddSong(builder: AddSongBuilder, onDisappear: @escaping () async -> Void) {
        navigateToAddSongCalled = true
    }

    func dismiss() {
        dismissCalled = true
    }
}
