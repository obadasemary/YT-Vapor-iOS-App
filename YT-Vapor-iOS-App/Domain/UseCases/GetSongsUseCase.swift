import Foundation

/// Use case that orchestrates the business logic for fetching songs
///
/// Responsibilities:
/// - Coordinates with the repository to fetch song data
/// - Could add business logic like filtering, sorting, or validation
/// - Provides a clear boundary between presentation and data layers
///
/// This use case follows the Single Responsibility Principle and can be
/// easily tested by mocking the repository protocol.
final class GetSongsUseCase: GetSongsUseCaseProtocol {
    private let repository: SongRepositoryProtocol

    /// Initializes the use case with a repository
    /// - Parameter repository: The repository conforming to SongRepositoryProtocol
    init(repository: SongRepositoryProtocol) {
        self.repository = repository
    }

    /// Executes the use case to fetch songs
    /// - Returns: An array of Song entities
    /// - Throws: Any error that occurs during the fetch operation
    func execute() async throws -> [Song] {
        try await repository.fetchSongs()
    }
}
