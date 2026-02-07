import Foundation

/// Protocol defining HTTP client operations
///
/// This protocol provides an abstraction over network operations,
/// enabling easy testing through mocks and allowing different
/// implementations (URLSession, Alamofire, etc.) to be swapped.
protocol HTTPClient {
    /// Fetches and decodes data from a given URL
    /// - Parameter url: The URL to fetch from
    /// - Returns: A decoded object of type T
    /// - Throws: NetworkError if the operation fails
    func fetch<T: Decodable>(from url: URL) async throws -> T
    
    /// Posts data to a URL and decodes the response
    /// - Parameters:
    ///   - data: The encodable data to post
    ///   - url: The URL to post to
    /// - Returns: A decoded object of type T
    /// - Throws: NetworkError if the operation fails
    func post<T: Decodable, U: Encodable>(_ data: U, to url: URL) async throws -> T
}
