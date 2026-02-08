import Foundation

/// Protocol defining the contract for updating an existing song
///
/// This protocol follows Clean Architecture principles:
/// - Defines a single responsibility use case
/// - Independent of implementation details
/// - Can be easily mocked for testing
protocol UpdateSongUseCaseProtocol {
    /// Updates an existing song with the provided details
    /// - Parameters:
    ///   - id: The unique identifier of the song to update
    ///   - title: The new song title
    ///   - artist: The new artist name
    /// - Returns: The updated Song entity
    /// - Throws: ValidationError or any repository error
    func execute(id: UUID, title: String, artist: String) async throws -> Song
}
