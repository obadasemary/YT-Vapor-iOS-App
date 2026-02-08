import Foundation

/// Repository implementation for song data access
///
/// This repository:
/// - Implements the SongRepositoryProtocol from the domain layer
/// - Uses HTTPClient to fetch data from the API
/// - Maps DTOs to domain entities
/// - Handles errors from the network layer
final class SongRepository: SongRepositoryProtocol {
    private let httpClient: HTTPClient
    private let endpoint: APIEndpoint

    /// Initializes the repository with dependencies
    /// - Parameters:
    ///   - httpClient: The HTTP client for network requests
    ///   - endpoint: The API endpoint to fetch from (defaults to .songs)
    init(httpClient: HTTPClient, endpoint: APIEndpoint = .songs) {
        self.httpClient = httpClient
        self.endpoint = endpoint
    }

    /// Fetches songs from the API and maps them to domain entities
    /// - Returns: An array of Song domain entities
    /// - Throws: NetworkError if the request fails or URL is invalid
    func fetchSongs() async throws -> [Song] {
        // Validate the endpoint URL
        guard let url = endpoint.url else {
            print("❌ Failed to create URL from: \(endpoint.baseURL + endpoint.path)")
            throw NetworkError.invalidURL
        }

        print("✅ Fetching from URL: \(url.absoluteString)")

        // Fetch DTOs from the API
        let dtos: [SongDTO] = try await httpClient.fetch(from: url)

        print("✅ Received \(dtos.count) songs from API")

        // Map DTOs to domain entities (filters out invalid entries)
        return dtos.toDomain()
    }
    
    /// Creates a new song via the API
    /// - Parameters:
    ///   - title: The song title
    ///   - artist: The artist name
    /// - Returns: The newly created Song domain entity
    /// - Throws: NetworkError if the request fails or URL is invalid
    func createSong(title: String, artist: String) async throws -> Song {
        // Validate the endpoint URL
        guard let url = endpoint.url else {
            print("❌ Failed to create URL from: \(endpoint.baseURL + endpoint.path)")
            throw NetworkError.invalidURL
        }
        
        print("✅ Creating song at URL: \(url.absoluteString)")
        
        // Create request DTO
        let createDTO = CreateSongDTO(title: title, artist: artist)
        
        // Post to API and receive response
        let responseDTO: SongDTO = try await httpClient.post(createDTO, to: url)
        
        print("✅ Successfully created song: \(responseDTO.title)")
        
        // Map DTO to domain entity
        guard let song = responseDTO.toDomain() else {
            throw NetworkError.decodingError
        }
        
        return song
    }

    /// Updates an existing song via the API
    /// - Parameters:
    ///   - id: The unique identifier of the song to update
    ///   - title: The new song title
    ///   - artist: The new artist name
    /// - Returns: The updated Song domain entity
    /// - Throws: NetworkError if the request fails or URL is invalid
    func updateSong(id: UUID, title: String, artist: String) async throws -> Song {
        let songEndpoint = APIEndpoint.song(id: id)
        guard let url = songEndpoint.url else {
            print("❌ Failed to create URL for song update")
            throw NetworkError.invalidURL
        }

        print("✅ Updating song at URL: \(url.absoluteString)")

        let updateDTO = UpdateSongDTO(title: title, artist: artist)
        let responseDTO: SongDTO = try await httpClient.put(updateDTO, to: url)

        print("✅ Successfully updated song: \(responseDTO.title)")

        guard let song = responseDTO.toDomain() else {
            throw NetworkError.decodingError
        }

        return song
    }

    /// Deletes a song via the API
    /// - Parameter id: The unique identifier of the song to delete
    /// - Throws: NetworkError if the request fails or URL is invalid
    func deleteSong(id: UUID) async throws {
        let songEndpoint = APIEndpoint.song(id: id)
        guard let url = songEndpoint.url else {
            print("❌ Failed to create URL for song deletion")
            throw NetworkError.invalidURL
        }

        print("✅ Deleting song at URL: \(url.absoluteString)")

        try await httpClient.delete(from: url)

        print("✅ Successfully deleted song with ID: \(id)")
    }
}
