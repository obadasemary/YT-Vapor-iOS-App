import Testing
import Foundation
@testable import YT_Vapor_iOS_App

/// Tests for SongDTO to Song domain mapping
@Suite("SongDTO Mapping Tests")
struct SongDTOMappingTests {

    // MARK: - Single DTO Mapping

    @Test("Valid DTO maps to domain Song successfully")
    func testValidDTOMapsSuccessfully() {
        let validUUID = UUID().uuidString
        let dto = SongDTO(
            id: validUUID,
            title: "Bohemian Rhapsody",
            artist: "Queen"
        )

        let song = dto.toDomain()

        #expect(song != nil)
        #expect(song?.id.uuidString == validUUID)
        #expect(song?.title == "Bohemian Rhapsody")
        #expect(song?.artist == "Queen")
    }

    @Test("DTO with invalid UUID returns nil")
    func testInvalidUUIDReturnsNil() {
        let dto = SongDTO(
            id: "not-a-valid-uuid",
            title: "Test Song",
            artist: "Test Artist"
        )

        let song = dto.toDomain()

        #expect(song == nil)
    }

    @Test("DTO with empty UUID string returns nil")
    func testEmptyUUIDReturnsNil() {
        let dto = SongDTO(
            id: "",
            title: "Test Song",
            artist: "Test Artist"
        )

        let song = dto.toDomain()

        #expect(song == nil)
    }

    // MARK: - Array Mapping

    @Test("Array of valid DTOs maps correctly")
    func testArrayOfValidDTOsMaps() {
        let dtos = [
            SongDTO(id: UUID().uuidString, title: "Song 1", artist: "Artist 1"),
            SongDTO(id: UUID().uuidString, title: "Song 2", artist: "Artist 2"),
            SongDTO(id: UUID().uuidString, title: "Song 3", artist: "Artist 3")
        ]

        let songs = dtos.toDomain()

        #expect(songs.count == 3)
        #expect(songs[0].title == "Song 1")
        #expect(songs[1].title == "Song 2")
        #expect(songs[2].title == "Song 3")
    }

    @Test("Array mapping filters out invalid DTOs")
    func testArrayMappingFiltersInvalidDTOs() {
        let dtos = [
            SongDTO(id: UUID().uuidString, title: "Valid Song 1", artist: "Artist 1"),
            SongDTO(id: "invalid-uuid", title: "Invalid Song", artist: "Artist 2"),
            SongDTO(id: UUID().uuidString, title: "Valid Song 2", artist: "Artist 3")
        ]

        let songs = dtos.toDomain()

        #expect(songs.count == 2)
        #expect(songs[0].title == "Valid Song 1")
        #expect(songs[1].title == "Valid Song 2")
    }

    @Test("Empty DTO array returns empty Song array")
    func testEmptyArrayReturnsEmpty() {
        let dtos: [SongDTO] = []

        let songs = dtos.toDomain()

        #expect(songs.isEmpty)
    }

    @Test("All invalid DTOs returns empty array")
    func testAllInvalidDTOsReturnsEmpty() {
        let dtos = [
            SongDTO(id: "invalid-1", title: "Song 1", artist: "Artist 1"),
            SongDTO(id: "invalid-2", title: "Song 2", artist: "Artist 2")
        ]

        let songs = dtos.toDomain()

        #expect(songs.isEmpty)
    }
}
