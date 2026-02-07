import Foundation

/// Network-specific errors that can occur during API communication
///
/// These errors provide type-safe error handling throughout the data layer
/// and can be easily mapped to user-friendly messages in the presentation layer.
enum NetworkError: Error, Equatable {
    /// The URL is malformed or invalid
    case invalidURL

    /// The server returned no data
    case noData

    /// Failed to decode the JSON response
    case decodingError
    
    /// Failed to encode the request body
    case encodingError

    /// HTTP request failed with a specific status code
    case httpError(statusCode: Int)

    /// Underlying system or URLSession error
    case underlying(Error)

    /// Equatable conformance for testing
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.noData, .noData),
             (.decodingError, .decodingError),
             (.encodingError, .encodingError):
            return true
        case (.httpError(let lhsCode), .httpError(let rhsCode)):
            return lhsCode == rhsCode
        case (.underlying(let lhsError), .underlying(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
