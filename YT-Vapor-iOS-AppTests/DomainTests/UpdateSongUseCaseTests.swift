import Testing
import Foundation
@testable import YT_Vapor_iOS_App

/// Tests for UpdateSongUseCase
@Suite("UpdateSongUseCase Tests")
struct UpdateSongUseCaseTests {

    // MARK: - Success Tests

    @Test("Successfully updates a song with valid inputs")
    func testUpdateSongSuccess() async throws {
        // Given
        let mockRepository = MockSongRepository()
        let useCase = await UpdateSongUseCase(repository: mockRepository)
        let songId = UUID()

        // When
        let song = try await useCase.execute(id: songId, title: "New Title", artist: "New Artist")

        // Then
        #expect(song.id == songId)
        #expect(song.title == "New Title")
        #expect(song.artist == "New Artist")
        #expect(mockRepository.updateSongCalled)
    }

    @Test("Trims whitespace from title and artist")
    func testTrimWhitespace() async throws {
        // Given
        let mockRepository = MockSongRepository()
        let useCase = await UpdateSongUseCase(repository: mockRepository)

        // When
        let song = try await useCase.execute(id: UUID(), title: "  New Title  ", artist: "  New Artist  ")

        // Then
        #expect(song.title == "New Title")
        #expect(song.artist == "New Artist")
    }

    // MARK: - Validation Tests

    @Test("Throws error for empty title")
    func testEmptyTitle() async {
        // Given
        let mockRepository = MockSongRepository()
        let useCase = await UpdateSongUseCase(repository: mockRepository)

        // When/Then
        await #expect(throws: ValidationError.emptyTitle) {
            try await useCase.execute(id: UUID(), title: "", artist: "Artist")
        }
        #expect(!mockRepository.updateSongCalled)
    }

    @Test("Throws error for whitespace-only title")
    func testWhitespaceOnlyTitle() async {
        let mockRepository = MockSongRepository()
        let useCase = await UpdateSongUseCase(repository: mockRepository)

        await #expect(throws: ValidationError.emptyTitle) {
            try await useCase.execute(id: UUID(), title: "   ", artist: "Artist")
        }
        #expect(!mockRepository.updateSongCalled)
    }

    @Test("Throws error for empty artist")
    func testEmptyArtist() async {
        // Given
        let mockRepository = MockSongRepository()
        let useCase = await UpdateSongUseCase(repository: mockRepository)

        // When/Then
        await #expect(throws: ValidationError.emptyArtist) {
            try await useCase.execute(id: UUID(), title: "Title", artist: "")
        }
        #expect(!mockRepository.updateSongCalled)
    }

    @Test("Throws error for whitespace-only artist")
    func testWhitespaceOnlyArtist() async {
        let mockRepository = MockSongRepository()
        let useCase = await UpdateSongUseCase(repository: mockRepository)

        await #expect(throws: ValidationError.emptyArtist) {
            try await useCase.execute(id: UUID(), title: "Title", artist: "   ")
        }
        #expect(!mockRepository.updateSongCalled)
    }

    // MARK: - Mock Repository

    private final class MockSongRepository: SongRepositoryProtocol {
        var updateSongCalled = false

        func fetchSongs() async throws -> [Song] { [] }

        func createSong(title: String, artist: String) async throws -> Song {
            Song(id: UUID(), title: title, artist: artist)
        }

        func updateSong(id: UUID, title: String, artist: String) async throws -> Song {
            updateSongCalled = true
            return Song(id: id, title: title, artist: artist)
        }

        func deleteSong(id: UUID) async throws {}
    }
}
