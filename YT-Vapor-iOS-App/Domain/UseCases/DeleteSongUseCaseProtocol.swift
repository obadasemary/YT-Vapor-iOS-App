import Foundation

/// Protocol defining the contract for deleting a song
///
/// This protocol follows Clean Architecture principles:
/// - Defines a single responsibility use case
/// - Independent of implementation details
/// - Can be easily mocked for testing
protocol DeleteSongUseCaseProtocol {
    /// Deletes a song by its identifier
    /// - Parameter id: The unique identifier of the song to delete
    /// - Throws: Any error that occurs during deletion
    func execute(id: UUID) async throws
}
