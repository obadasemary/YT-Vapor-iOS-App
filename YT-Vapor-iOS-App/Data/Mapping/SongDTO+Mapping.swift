import Foundation

/// Mapping extension to convert SongDTO to domain Song entity
extension SongDTO {
    /// Converts this DTO to a domain Song entity
    /// - Returns: A Song entity if the ID is a valid UUID, nil otherwise
    func toDomain() -> Song? {
        // Validate that the ID string is a valid UUID
        guard let uuid = UUID(uuidString: id) else {
            return nil
        }

        return Song(
            id: uuid,
            title: title,
            artist: artist ?? "Unknown Artist"
        )
    }
}

/// Mapping extension for arrays of SongDTOs
extension Array where Element == SongDTO {
    /// Converts an array of DTOs to an array of domain Song entities
    /// - Returns: An array of Songs, filtering out any invalid entries
    func toDomain() -> [Song] {
        compactMap { $0.toDomain() }
    }
}
