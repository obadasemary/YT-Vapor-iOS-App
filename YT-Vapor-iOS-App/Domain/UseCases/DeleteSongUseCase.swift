import Foundation

/// Use case for deleting a song
///
/// This use case:
/// - Implements DeleteSongUseCaseProtocol
/// - Delegates to the repository to delete songs
final class DeleteSongUseCase: DeleteSongUseCaseProtocol {
    private let repository: SongRepositoryProtocol

    /// Initializes the use case with a repository
    /// - Parameter repository: The repository for song data access
    init(repository: SongRepositoryProtocol) {
        self.repository = repository
    }

    /// Deletes a song by its identifier
    /// - Parameter id: The unique identifier of the song to delete
    /// - Throws: Any error that occurs during deletion
    func execute(id: UUID) async throws {
        try await repository.deleteSong(id: id)
    }
}
