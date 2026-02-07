import Foundation

/// Protocol defining the contract for song data access
///
/// This protocol follows the Dependency Inversion Principle:
/// - The Domain layer defines what it needs (this protocol)
/// - The Data layer implements it (SongRepository)
///
/// This allows the domain to remain independent of implementation details.
protocol SongRepositoryProtocol {
    /// Fetches a list of songs from the data source
    /// - Returns: An array of Song entities
    /// - Throws: Any error that occurs during data fetching
    func fetchSongs() async throws -> [Song]
    
    /// Creates a new song with the provided details
    /// - Parameters:
    ///   - title: The song title
    ///   - artist: The artist name
    /// - Returns: The newly created Song entity
    /// - Throws: Any error that occurs during song creation
    func createSong(title: String, artist: String) async throws -> Song
}
