import Foundation

/// Data Transfer Object representing a song from the API
///
/// This DTO matches the JSON structure returned by the Vapor backend.
/// It's kept separate from the domain Song entity to:
/// - Decouple API contract from domain model
/// - Allow independent evolution of API and domain
/// - Enable validation and transformation during mapping
struct SongDTO: Decodable {
    let id: String
    let title: String
    let artist: String?
}
