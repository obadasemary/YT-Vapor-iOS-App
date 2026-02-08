import Foundation
import Observation

/// ViewModel for the songs list feature
///
/// This ViewModel:
/// - Uses the @Observable macro for modern SwiftUI state management
/// - Coordinates with the GetSongsUseCase to fetch songs
/// - Manages UI state through ViewState enum
/// - Handles errors gracefully
@Observable
@MainActor
final class SongsListViewModel {
    private let getSongsUseCase: GetSongsUseCaseProtocol
    private let deleteSongUseCase: DeleteSongUseCaseProtocol
    private let router: SongsListRouterProtocol
    private let addSongBuilder: AddSongBuilder
    private let container: AppDependencyContainer

    /// The current state of the view
    var state: ViewState<[Song]> = .idle

    /// Song pending deletion confirmation (nil when no confirmation is shown)
    var songPendingDeletion: Song? = nil

    /// Tracks if a load operation is currently in progress
    private var isLoading = false

    /// Initializes the view model with dependencies
    /// - Parameters:
    ///   - getSongsUseCase: The use case for fetching songs
    ///   - deleteSongUseCase: The use case for deleting songs
    ///   - router: The router for navigation
    ///   - addSongBuilder: Builder for creating the Add Song view
    ///   - container: The DI container for creating child builders
    init(
        getSongsUseCase: GetSongsUseCaseProtocol,
        deleteSongUseCase: DeleteSongUseCaseProtocol,
        router: SongsListRouterProtocol,
        addSongBuilder: AddSongBuilder,
        container: AppDependencyContainer
    ) {
        self.getSongsUseCase = getSongsUseCase
        self.deleteSongUseCase = deleteSongUseCase
        self.router = router
        self.addSongBuilder = addSongBuilder
        self.container = container
    }

    /// Loads songs, showing the skeleton loading state (used on initial load)
    func loadSongs() async {
        guard !isLoading else { return }
        isLoading = true
        state = .loading
        await fetchSongs()
        isLoading = false
    }

    /// Refreshes songs without changing the current state (used for pull-to-refresh)
    func refreshSongs() async {
        guard !isLoading else { return }
        isLoading = true
        await fetchSongs()
        isLoading = false
    }

    private func fetchSongs() async {
        do {
            let songs = try await getSongsUseCase.execute()
            if !Task.isCancelled {
                state = .loaded(songs)
            }
        } catch is CancellationError {
            // Keep previous state
        } catch {
            if !Task.isCancelled {
                state = .error(error)
            }
        }
    }

    /// Navigates to the Add Song screen
    func navigateToAddSong() {
        router.navigateToAddSong(builder: addSongBuilder)
    }

    /// Navigates to the Edit Song screen for the given song
    /// - Parameter song: The song to edit
    func navigateToEditSong(_ song: Song) {
        let editSongBuilder = EditSongBuilder(
            container: container,
            songsListRouter: router,
            song: song,
            onSongUpdated: {
                await self.refreshSongs()
            },
            onSongDeleted: {
                await self.refreshSongs()
            }
        )
        router.navigateToEditSong(builder: editSongBuilder)
    }

    /// Requests deletion confirmation for a song (used for swipe-to-delete)
    /// - Parameter song: The song to confirm deletion for
    func confirmDeleteSong(_ song: Song) {
        songPendingDeletion = song
    }

    /// Deletes a specific song
    func deleteSong(_ song: Song) async {
        songPendingDeletion = nil
        do {
            try await deleteSongUseCase.execute(id: song.id)
            await refreshSongs()
        } catch {
            state = .error(error)
        }
    }
}
