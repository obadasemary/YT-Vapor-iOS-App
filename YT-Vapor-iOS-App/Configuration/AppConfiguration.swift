import Foundation

/// Application configuration loaded from Config.plist
/// This allows environment-specific settings without hardcoding sensitive data
struct AppConfiguration {

    // MARK: - Properties

    /// The base URL for the API backend
    let apiBaseURL: String

    /// List of domains that should allow insecure HTTP connections
    let httpExceptionDomains: [String]

    // MARK: - Singleton

    static let shared: AppConfiguration = {
        guard let config = AppConfiguration.loadFromPlist() else {
            fatalError("""
                ❌ Config.plist not found!

                Please create Config.plist from Config.plist.template:
                1. Copy Config.plist.template to Config.plist
                2. Update the values for your environment
                3. Config.plist is gitignored, so your settings stay private
                """)
        }
        return config
    }()

    // MARK: - Initialization

    private init(apiBaseURL: String, httpExceptionDomains: [String]) {
        self.apiBaseURL = apiBaseURL
        self.httpExceptionDomains = httpExceptionDomains
    }

    // MARK: - Loading

    /// Loads configuration from Config.plist in the main bundle
    private static func loadFromPlist() -> AppConfiguration? {
        // Look for Config.plist in the main bundle
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let xml = FileManager.default.contents(atPath: path),
              let config = try? PropertyListDecoder().decode(ConfigPlist.self, from: xml) else {
            return nil
        }

        return AppConfiguration(
            apiBaseURL: config.apiBaseURL,
            httpExceptionDomains: config.httpExceptionDomains
        )
    }
}

// MARK: - Plist Codable Structure

private struct ConfigPlist: Codable {
    let apiBaseURL: String
    let httpExceptionDomains: [String]

    enum CodingKeys: String, CodingKey {
        case apiBaseURL = "API_BASE_URL"
        case httpExceptionDomains = "HTTP_EXCEPTION_DOMAINS"
    }
}
