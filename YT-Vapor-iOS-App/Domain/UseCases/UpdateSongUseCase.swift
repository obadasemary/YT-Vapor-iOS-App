import Foundation

/// Use case for updating an existing song
///
/// This use case:
/// - Implements UpdateSongUseCaseProtocol
/// - Validates input using the same rules as CreateSongUseCase
/// - Delegates to the repository for data persistence
final class UpdateSongUseCase: UpdateSongUseCaseProtocol {
    private let repository: SongRepositoryProtocol

    /// Initializes the use case with a repository
    /// - Parameter repository: The repository for song data access
    init(repository: SongRepositoryProtocol) {
        self.repository = repository
    }

    /// Updates an existing song
    /// - Parameters:
    ///   - id: The unique identifier of the song to update
    ///   - title: The song title (will be validated)
    ///   - artist: The artist name (will be validated)
    /// - Returns: The updated Song entity
    /// - Throws: ValidationError or any repository error
    func execute(id: UUID, title: String, artist: String) async throws -> Song {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedArtist = artist.trimmingCharacters(in: .whitespaces)

        guard !trimmedTitle.isEmpty else {
            throw ValidationError.emptyTitle
        }

        guard !trimmedArtist.isEmpty else {
            throw ValidationError.emptyArtist
        }

        return try await repository.updateSong(id: id, title: trimmedTitle, artist: trimmedArtist)
    }
}
