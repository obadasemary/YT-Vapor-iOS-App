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
    private let router: SongsListRouterProtocol
    private let addSongBuilder: AddSongBuilder

    /// The current state of the view
    var state: ViewState<[Song]> = .idle

    /// Tracks if a load operation is currently in progress
    private var isLoading = false

    /// Initializes the view model with dependencies
    /// - Parameters:
    ///   - getSongsUseCase: The use case for fetching songs
    ///   - router: The router for navigation
    ///   - addSongBuilder: Builder for creating the Add Song view
    init(getSongsUseCase: GetSongsUseCaseProtocol, router: SongsListRouterProtocol, addSongBuilder: AddSongBuilder) {
        self.getSongsUseCase = getSongsUseCase
        self.router = router
        self.addSongBuilder = addSongBuilder
    }

    /// Loads songs from the data source
    ///
    /// This method:
    /// - Prevents multiple simultaneous requests
    /// - Sets state to loading
    /// - Executes the use case
    /// - Updates state based on success or failure
    /// - Handles cancellation gracefully
    func loadSongs() async {
        // Prevent multiple simultaneous requests
        guard !isLoading else { return }

        isLoading = true
        state = .loading

        do {
            let songs = try await getSongsUseCase.execute()
            if !Task.isCancelled {
                state = .loaded(songs)
            }
        } catch is CancellationError {
            // Ignore cancellation errors - don't show them to the user
            // Keep the previous state
        } catch {
            if !Task.isCancelled {
                state = .error(error)
            }
        }

        isLoading = false
    }

    /// Navigates to the Add Song screen
    func navigateToAddSong() {
        router.navigateToAddSong(builder: addSongBuilder)
    }
}
