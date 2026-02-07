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
    /// - Returns: A configured SongsListViewModel
    func makeSongsListViewModel(router: SongsListRouterProtocol, addSongBuilder: AddSongBuilder) -> SongsListViewModel {
        let useCase = makeGetSongsUseCase()
        return SongsListViewModel(getSongsUseCase: useCase, router: router, addSongBuilder: addSongBuilder)
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

    /// Creates a SongRepository with its dependencies
    private func makeSongRepository() -> SongRepositoryProtocol {
        return SongRepository(httpClient: httpClient)
    }
}
