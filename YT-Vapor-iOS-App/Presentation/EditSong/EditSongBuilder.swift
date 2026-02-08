import SwiftUI

/// Builder for composing the Edit Song view with its dependencies
///
/// This builder:
/// - Follows the Builder pattern from Clean Architecture
/// - Centralizes dependency injection for the Edit Song feature
/// - Creates the view with all required dependencies
/// - Keeps views testable and independent from DI container
@MainActor
@Observable
class EditSongBuilder {

    // MARK: - Properties

    private let container: AppDependencyContainer
    private let songsListRouter: SongsListRouterProtocol
    private let song: Song
    private let onSongUpdated: () async -> Void
    private let onSongDeleted: () async -> Void

    // MARK: - Initialization

    /// Creates a new builder with the dependency container and configuration
    /// - Parameters:
    ///   - container: The app's dependency container
    ///   - songsListRouter: The router from the parent Songs List screen
    ///   - song: The song to edit
    ///   - onSongUpdated: Async callback when song is successfully updated
    ///   - onSongDeleted: Async callback when song is successfully deleted
    init(
        container: AppDependencyContainer,
        songsListRouter: SongsListRouterProtocol,
        song: Song,
        onSongUpdated: @escaping () async -> Void,
        onSongDeleted: @escaping () async -> Void
    ) {
        self.container = container
        self.songsListRouter = songsListRouter
        self.song = song
        self.onSongUpdated = onSongUpdated
        self.onSongDeleted = onSongDeleted
    }

    // MARK: - Build Methods

    /// Builds the Edit Song view with all dependencies
    /// - Returns: A fully configured EditSongView
    func build() -> EditSongView {
        let viewModel = container.makeEditSongViewModel(
            song: song,
            onSongUpdated: {
                self.songsListRouter.dismiss()
                await self.onSongUpdated()
            },
            onSongDeleted: {
                self.songsListRouter.dismiss()
                await self.onSongDeleted()
            }
        )

        return EditSongView(viewModel: viewModel)
    }
}
