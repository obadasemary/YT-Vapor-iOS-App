import Foundation

/// Data Transfer Object for updating an existing song
///
/// This DTO represents the request body sent to the API
/// when updating a song.
struct UpdateSongDTO: Encodable {
    let title: String
    let artist: String
}
