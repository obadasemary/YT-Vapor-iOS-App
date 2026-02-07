import Foundation

/// Protocol defining the contract for creating a new song
///
/// This protocol follows Clean Architecture principles:
/// - Defines a single responsibility use case
/// - Independent of implementation details
/// - Can be easily mocked for testing
protocol CreateSongUseCaseProtocol {
    /// Creates a new song with the provided details
    /// - Parameters:
    ///   - title: The song title
    ///   - artist: The artist name
    /// - Returns: The newly created Song entity
    /// - Throws: Any error that occurs during song creation
    func execute(title: String, artist: String) async throws -> Song
}
