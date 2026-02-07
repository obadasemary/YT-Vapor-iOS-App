import Foundation

/// Domain entity representing a song
///
/// This is a pure Swift model with no framework dependencies.
/// Used throughout the domain and presentation layers.
struct Song: Identifiable, Equatable {
    let id: UUID
    let title: String
    let artist: String
}
