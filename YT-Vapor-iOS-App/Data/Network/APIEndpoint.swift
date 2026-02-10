import Foundation

/// Defines API endpoints with configuration
///
/// This enum centralizes all API endpoint configuration.
/// Base URL is loaded from Config.plist (gitignored) for environment-specific settings.
enum APIEndpoint {
    case songs
    case song(id: UUID)

    /// The base URL for the API, loaded from AppConfiguration
    var baseURL: String {
        AppConfiguration.shared.apiBaseURL
    }

    /// The path component for this specific endpoint
    var path: String {
        switch self {
        case .songs:
            return "songs"
        case .song(let id):
            return "songs/\(id.uuidString)"
        }
    }

    /// The complete URL constructed from base URL and path
    var url: URL? {
        URL(string: baseURL + path)
    }
}
