import SwiftUI
import SUIRouting

/// Builder for composing the Songs List view with its dependencies
///
/// This builder:
/// - Follows the Builder pattern from Clean Architecture
/// - Centralizes dependency injection for the Songs List feature
/// - Creates the view with all required dependencies (ViewModel, Router)
/// - Integrates with SUIRouting for declarative navigation
/// - Keeps views testable and independent from DI container
///
/// Usage:
/// ```swift
/// let builder = SongsListBuilder(container: container)
/// let view = builder.build(router: environmentRouter)
/// ```
@MainActor
@Observable
final class SongsListBuilder {

    // MARK: - Properties

    private let container: AppDependencyContainer

    // MARK: - Initialization

    /// Creates a new builder with the dependency container
    /// - Parameter container: The app's dependency container
    init(container: AppDependencyContainer) {
        self.container = container
    }

    // MARK: - Build Methods

    /// Builds the Songs List view with all dependencies
    /// - Parameter router: The SUIRouting router from environment
    /// - Returns: A fully configured SongsListView
    func build(router: Router) -> SongsListView {
        let songsListRouter = SongsListRouter(router: router)
        
        // Placeholder for viewModel (will be set below)
        var viewModel: SongsListViewModel!
        
        // Create addSongBuilder with callback that reloads songs
        let addSongBuilder = AddSongBuilder(
            container: container,
            songsListRouter: songsListRouter,
            onSongAdded: {
                await viewModel.loadSongs()
            }
        )
        
        // Create viewModel
        viewModel = container.makeSongsListViewModel(
            router: songsListRouter,
            addSongBuilder: addSongBuilder
        )

        return SongsListView(
            viewModel: viewModel,
            addSongBuilder: addSongBuilder
        )
    }
}
