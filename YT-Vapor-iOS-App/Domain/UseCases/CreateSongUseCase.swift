import Foundation

/// Use case for creating a new song
///
/// This use case:
/// - Implements CreateSongUseCaseProtocol
/// - Coordinates with the repository to create songs
/// - Validates business rules if needed
/// - Returns domain entities
final class CreateSongUseCase: CreateSongUseCaseProtocol {
    private let repository: SongRepositoryProtocol
    
    /// Initializes the use case with a repository
    /// - Parameter repository: The repository for song data access
    init(repository: SongRepositoryProtocol) {
        self.repository = repository
    }
    
    /// Creates a new song
    /// - Parameters:
    ///   - title: The song title (will be validated)
    ///   - artist: The artist name (will be validated)
    /// - Returns: The newly created Song entity
    /// - Throws: ValidationError or any repository error
    func execute(title: String, artist: String) async throws -> Song {
        // Validate input
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedArtist = artist.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedTitle.isEmpty else {
            throw ValidationError.emptyTitle
        }
        
        guard !trimmedArtist.isEmpty else {
            throw ValidationError.emptyArtist
        }
        
        // Delegate to repository
        return try await repository.createSong(title: trimmedTitle, artist: trimmedArtist)
    }
}

/// Validation errors for song creation
enum ValidationError: LocalizedError {
    case emptyTitle
    case emptyArtist
    
    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Song title cannot be empty"
        case .emptyArtist:
            return "Artist name cannot be empty"
        }
    }
}
