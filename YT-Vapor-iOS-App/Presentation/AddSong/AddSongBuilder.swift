import SwiftUI

/// Builder for composing the Add Song view with its dependencies
///
/// This builder:
/// - Follows the Builder pattern from Clean Architecture
/// - Centralizes dependency injection for the Add Song feature
/// - Creates the view with all required dependencies (ViewModel, Router callback)
/// - Keeps views testable and independent from DI container
///
/// Usage:
/// ```swift
/// let builder = AddSongBuilder(container: container, songsListRouter: router)
/// let view = builder.build()
/// ```
@MainActor
@Observable
class AddSongBuilder {

    // MARK: - Properties

    private let container: AppDependencyContainer
    private let songsListRouter: SongsListRouterProtocol
    private let onSongAdded: () async -> Void

    // MARK: - Initialization

    /// Creates a new builder with the dependency container and parent router
    /// - Parameters:
    ///   - container: The app's dependency container
    ///   - songsListRouter: The router from the parent Songs List screen
    ///   - onSongAdded: Async callback to invoke when a song is successfully added
    init(
        container: AppDependencyContainer,
        songsListRouter: SongsListRouterProtocol,
        onSongAdded: @escaping () async -> Void
    ) {
        self.container = container
        self.songsListRouter = songsListRouter
        self.onSongAdded = onSongAdded
    }

    // MARK: - Build Methods

    /// Builds the Add Song view with all dependencies
    /// - Returns: A fully configured AddSongView
    func build() -> AddSongView {
        let viewModel = container.makeAddSongViewModel(onSongAdded: {
            // Dismiss the sheet and reload songs when a song is added
            self.songsListRouter.dismiss()
            await self.onSongAdded()
        })

        return AddSongView(viewModel: viewModel)
    }
}
