import Testing
import Foundation
@testable import YT_Vapor_iOS_App

/// Tests for CreateSongUseCase
///
/// These tests verify:
/// - Successful song creation
/// - Input validation
/// - Error handling
/// - Interaction with repository
@Suite("CreateSongUseCase Tests")
struct CreateSongUseCaseTests {
    
    // MARK: - Success Tests
    
    @Test("Successfully creates a song with valid inputs")
    func testCreateSongSuccess() async throws {
        // Given
        let mockRepository = MockSongRepository()
        let useCase = await CreateSongUseCase(repository: mockRepository)
        let title = "Bohemian Rhapsody"
        let artist = "Queen"
        
        // When
        let song = try await useCase.execute(title: title, artist: artist)
        
        // Then
        #expect(song.title == title)
        #expect(song.artist == artist)
        #expect(mockRepository.createSongCalled)
    }
    
    @Test("Trims whitespace from title and artist")
    func testTrimWhitespace() async throws {
        // Given
        let mockRepository = MockSongRepository()
        let useCase = await CreateSongUseCase(repository: mockRepository)
        let title = "  Bohemian Rhapsody  "
        let artist = "  Queen  "
        
        // When
        let song = try await useCase.execute(title: title, artist: artist)
        
        // Then
        #expect(song.title == "Bohemian Rhapsody")
        #expect(song.artist == "Queen")
    }
    
    // MARK: - Validation Tests
    
    @Test("Throws error for empty title")
    func testEmptyTitle() async {
        // Given
        let mockRepository = MockSongRepository()
        let useCase = await CreateSongUseCase(repository: mockRepository)
        
        // When/Then
        await #expect(throws: ValidationError.emptyTitle) {
            try await useCase.execute(title: "", artist: "Queen")
        }
        #expect(!mockRepository.createSongCalled)
    }
    
    @Test("Throws error for whitespace-only title")
    func testWhitespaceOnlyTitle() async {
        // Given
        let mockRepository = MockSongRepository()
        let useCase = await CreateSongUseCase(repository: mockRepository)
        
        // When/Then
        await #expect(throws: ValidationError.emptyTitle) {
            try await useCase.execute(title: "   ", artist: "Queen")
        }
        #expect(!mockRepository.createSongCalled)
    }
    
    @Test("Throws error for empty artist")
    func testEmptyArtist() async {
        // Given
        let mockRepository = MockSongRepository()
        let useCase = await CreateSongUseCase(repository: mockRepository)
        
        // When/Then
        await #expect(throws: ValidationError.emptyArtist) {
            try await useCase.execute(title: "Bohemian Rhapsody", artist: "")
        }
        #expect(!mockRepository.createSongCalled)
    }
    
    @Test("Throws error for whitespace-only artist")
    func testWhitespaceOnlyArtist() async {
        // Given
        let mockRepository = MockSongRepository()
        let useCase = await CreateSongUseCase(repository: mockRepository)
        
        // When/Then
        await #expect(throws: ValidationError.emptyArtist) {
            try await useCase.execute(title: "Bohemian Rhapsody", artist: "   ")
        }
        #expect(!mockRepository.createSongCalled)
    }
    
    // MARK: - Mock Repository
    
    private final class MockSongRepository: SongRepositoryProtocol {
        var createSongCalled = false

        func fetchSongs() async throws -> [Song] { [] }

        func createSong(title: String, artist: String) async throws -> Song {
            createSongCalled = true
            return Song(id: UUID(), title: title, artist: artist)
        }

        func updateSong(id: UUID, title: String, artist: String) async throws -> Song {
            Song(id: id, title: title, artist: artist)
        }

        func deleteSong(id: UUID) async throws {}
    }
}
