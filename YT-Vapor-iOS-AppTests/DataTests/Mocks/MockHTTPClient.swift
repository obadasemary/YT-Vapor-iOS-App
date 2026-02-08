import Foundation
@testable import YT_Vapor_iOS_App

/// Mock HTTP client for testing
///
/// This mock allows tests to inject pre-configured responses
/// without making actual network requests.
final class MockHTTPClient: HTTPClient {
    private let result: Result<Any, Error>

    /// Initializes with a success result
    /// - Parameter data: The data to return on fetch
    init<T>(returning data: T) {
        self.result = .success(data)
    }

    /// Initializes with an error result
    /// - Parameter error: The error to throw on fetch
    init(throwing error: Error) {
        self.result = .failure(error)
    }

    /// Mocked fetch implementation
    func fetch<T: Decodable>(from url: URL) async throws -> T {
        switch result {
        case .success(let data):
            guard let typedData = data as? T else {
                throw NetworkError.decodingError
            }
            return typedData

        case .failure(let error):
            throw error
        }
    }
    
    /// Mocked post implementation
    func post<T: Decodable, U: Encodable>(_ data: U, to url: URL) async throws -> T {
        switch result {
        case .success(let responseData):
            guard let typedData = responseData as? T else {
                throw NetworkError.decodingError
            }
            return typedData

        case .failure(let error):
            throw error
        }
    }

    /// Mocked put implementation
    func put<T: Decodable, U: Encodable>(_ data: U, to url: URL) async throws -> T {
        switch result {
        case .success(let responseData):
            guard let typedData = responseData as? T else {
                throw NetworkError.decodingError
            }
            return typedData

        case .failure(let error):
            throw error
        }
    }

    /// Mocked delete implementation
    func delete(from url: URL) async throws {
        switch result {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
}
