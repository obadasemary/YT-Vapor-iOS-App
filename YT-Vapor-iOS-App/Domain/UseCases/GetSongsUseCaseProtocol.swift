import Foundation

/// Protocol defining the contract for fetching songs use case
///
/// This protocol allows the presentation layer to depend on an abstraction
/// rather than a concrete implementation, enabling easy mocking in tests.
protocol GetSongsUseCaseProtocol {
    /// Executes the use case to fetch songs
    /// - Returns: An array of Song entities
    /// - Throws: Any error that occurs during the fetch operation
    func execute() async throws -> [Song]
}
