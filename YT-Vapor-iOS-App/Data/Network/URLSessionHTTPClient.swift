import Foundation

/// URLSession-based implementation of HTTPClient
///
/// This implementation uses the standard URLSession API with Swift concurrency
/// to perform network requests and decode JSON responses.
final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    /// Initializes the HTTP client with a URLSession
    /// - Parameter session: The URLSession to use (defaults to configured session)
    init(session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        return URLSession(configuration: configuration)
    }()) {
        self.session = session
    }

    /// Fetches and decodes data from a URL
    /// - Parameter url: The URL to fetch from
    /// - Returns: A decoded object of type T
    /// - Throws: NetworkError for various failure scenarios
    func fetch<T: Decodable>(from url: URL) async throws -> T {
        // Perform the network request
        let (data, response) = try await session.data(from: url)

        // Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.underlying(URLError(.badServerResponse))
        }

        // Check for successful status code (200-299)
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        // Decode the JSON response
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    /// Posts data to a URL and decodes the response
    /// - Parameters:
    ///   - data: The encodable data to post
    ///   - url: The URL to post to
    /// - Returns: A decoded object of type T
    /// - Throws: NetworkError for various failure scenarios
    func post<T: Decodable, U: Encodable>(_ data: U, to url: URL) async throws -> T {
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode the body
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(data)
        } catch {
            throw NetworkError.encodingError
        }
        
        // Perform the network request
        let (responseData, response) = try await session.data(for: request)
        
        // Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.underlying(URLError(.badServerResponse))
        }
        
        // Check for successful status code (200-299)
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // Decode the JSON response
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: responseData)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
