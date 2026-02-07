import Testing
import Foundation
@testable import YT_Vapor_iOS_App

/// Tests for SongRepository
@Suite("SongRepository Tests")
struct SongRepositoryTests {

    @Test("Fetches songs successfully from HTTP client")
    func testFetchSongsSuccessfully() async throws {
        let uuid1 = UUID()
        let uuid2 = UUID()
        let mockDTOs = [
            SongDTO(id: uuid1.uuidString, title: "Song 1", artist: "Artist 1"),
            SongDTO(id: uuid2.uuidString, title: "Song 2", artist: "Artist 2")
        ]
        let mockClient = MockHTTPClient(returning: mockDTOs)
        let repository = SongRepository(httpClient: mockClient)

        let songs = try await repository.fetchSongs()

        #expect(songs.count == 2)
        #expect(songs[0].id == uuid1)
        #expect(songs[0].title == "Song 1")
        #expect(songs[0].artist == "Artist 1")
        #expect(songs[1].id == uuid2)
        #expect(songs[1].title == "Song 2")
    }

    @Test("Throws error when HTTP client fails")
    func testThrowsErrorWhenHTTPClientFails() async {
        let mockClient = MockHTTPClient(throwing: NetworkError.noData)
        let repository = SongRepository(httpClient: mockClient)

        do {
            _ = try await repository.fetchSongs()
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error as? NetworkError == .noData)
        }
    }

    @Test("Filters out DTOs with invalid UUIDs")
    func testFiltersInvalidUUIDs() async throws {
        let validUUID = UUID()
        let mockDTOs = [
            SongDTO(id: validUUID.uuidString, title: "Valid Song", artist: "Artist 1"),
            SongDTO(id: "invalid-uuid", title: "Invalid Song", artist: "Artist 2")
        ]
        let mockClient = MockHTTPClient(returning: mockDTOs)
        let repository = SongRepository(httpClient: mockClient)

        let songs = try await repository.fetchSongs()

        #expect(songs.count == 1)
        #expect(songs[0].id == validUUID)
        #expect(songs[0].title == "Valid Song")
    }

    @Test("Returns empty array when all DTOs are invalid")
    func testReturnsEmptyArrayForAllInvalidDTOs() async throws {
        let mockDTOs = [
            SongDTO(id: "invalid-1", title: "Song 1", artist: "Artist 1"),
            SongDTO(id: "invalid-2", title: "Song 2", artist: "Artist 2")
        ]
        let mockClient = MockHTTPClient(returning: mockDTOs)
        let repository = SongRepository(httpClient: mockClient)

        let songs = try await repository.fetchSongs()

        #expect(songs.isEmpty)
    }

    @Test("Returns empty array when HTTP client returns empty array")
    func testReturnsEmptyArrayForEmptyResponse() async throws {
        let mockDTOs: [SongDTO] = []
        let mockClient = MockHTTPClient(returning: mockDTOs)
        let repository = SongRepository(httpClient: mockClient)

        let songs = try await repository.fetchSongs()

        #expect(songs.isEmpty)
    }
}
