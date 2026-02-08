import Foundation

/// Dependency Injection container for the application
///
/// This container:
/// - Creates and manages application dependencies
/// - Provides factory methods for creating views with their dependencies
/// - Ensures proper dependency graph construction
/// - Makes dependencies explicit and testable
///
/// Usage:
/// ```
/// let container = AppDependencyContainer()
/// let songsView = container.makeSongsListView()
/// ```
class AppDependencyContainer {

    // MARK: - Singletons

    /// Shared HTTP client instance
    private lazy var httpClient: HTTPClient = URLSessionHTTPClient()

    // MARK: - Internal Factories (used by Builders)

    /// Creates a SongsListViewModel with its dependencies
    /// - Parameters:
    ///   - router: The router for navigation
    ///   - addSongBuilder: Builder for creating the Add Song view
    ///   - container: The DI container for creating child builders
    /// - Returns: A configured SongsListViewModel
    func makeSongsListViewModel(
        router: SongsListRouterProtocol,
        addSongBuilder: AddSongBuilder,
        container: AppDependencyContainer
    ) -> SongsListViewModel {
        let getSongsUseCase = makeGetSongsUseCase()
        let deleteSongUseCase = makeDeleteSongUseCase()
        return SongsListViewModel(
            getSongsUseCase: getSongsUseCase,
            deleteSongUseCase: deleteSongUseCase,
            router: router,
            addSongBuilder: addSongBuilder,
            container: container
        )
    }

    /// Creates a GetSongsUseCase with its dependencies
    private func makeGetSongsUseCase() -> GetSongsUseCase {
        let repository = makeSongRepository()
        return GetSongsUseCase(repository: repository)
    }
    
    /// Creates an AddSongViewModel with its dependencies
    /// - Parameter onSongAdded: Async callback to invoke when a song is successfully added
    /// - Returns: A configured AddSongViewModel
    func makeAddSongViewModel(onSongAdded: @escaping () async -> Void) -> AddSongViewModel {
        let useCase = makeCreateSongUseCase()
        return AddSongViewModel(createSongUseCase: useCase, onSongAdded: onSongAdded)
    }
    
    /// Creates a CreateSongUseCase with its dependencies
    private func makeCreateSongUseCase() -> CreateSongUseCase {
        let repository = makeSongRepository()
        return CreateSongUseCase(repository: repository)
    }

    /// Creates an UpdateSongUseCase with its dependencies
    private func makeUpdateSongUseCase() -> UpdateSongUseCase {
        let repository = makeSongRepository()
        return UpdateSongUseCase(repository: repository)
    }

    /// Creates a DeleteSongUseCase with its dependencies
    func makeDeleteSongUseCase() -> DeleteSongUseCase {
        let repository = makeSongRepository()
        return DeleteSongUseCase(repository: repository)
    }

    /// Creates an EditSongViewModel with its dependencies
    /// - Parameters:
    ///   - song: The song to edit
    ///   - onSongUpdated: Async callback when song is successfully updated
    ///   - onSongDeleted: Async callback when song is successfully deleted
    /// - Returns: A configured EditSongViewModel
    func makeEditSongViewModel(
        song: Song,
        onSongUpdated: @escaping () async -> Void,
        onSongDeleted: @escaping () async -> Void
    ) -> EditSongViewModel {
        let updateUseCase = makeUpdateSongUseCase()
        let deleteUseCase = makeDeleteSongUseCase()
        return EditSongViewModel(
            song: song,
            updateSongUseCase: updateUseCase,
            deleteSongUseCase: deleteUseCase,
            onSongUpdated: onSongUpdated,
            onSongDeleted: onSongDeleted
        )
    }

    /// Creates a SongRepository with its dependencies
    private func makeSongRepository() -> SongRepositoryProtocol {
        return SongRepository(httpClient: httpClient)
    }
}
