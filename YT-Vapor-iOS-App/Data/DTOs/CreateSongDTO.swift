import Foundation

/// Data Transfer Object for creating a new song
///
/// This DTO represents the request body sent to the API
/// when creating a new song.
struct CreateSongDTO: Encodable {
    let title: String
    let artist: String
}
