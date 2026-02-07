import Foundation

/// Defines API endpoints with configuration
///
/// This enum centralizes all API endpoint configuration, making it easy
/// to modify base URLs, paths, or add new endpoints.
enum APIEndpoint {
    case songs

    /// The base URL for the API
    /// TODO: Replace with your actual Vapor backend URL
    /// For production, consider using environment variables or a configuration file
    var baseURL: String {
        "https://localhost:8080/"
    }

    /// The path component for this specific endpoint
    var path: String {
        switch self {
        case .songs:
            return "songs"
        }
    }

    /// The complete URL constructed from base URL and path
    var url: URL? {
        URL(string: baseURL + path)
    }
}
