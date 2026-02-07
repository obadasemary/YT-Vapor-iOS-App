import Testing
import Foundation
@testable import YT_Vapor_iOS_App

/// Tests for GetSongsUseCase
@Suite("GetSongsUseCase Tests")
struct GetSongsUseCaseTests {

    @Test("Execute successfully fetches songs from repository")
    func testExecuteSuccessfully() async throws {
        let mockSongs = [
            Song(id: UUID(), title: "Test Song 1", artist: "Artist 1"),
            Song(id: UUID(), title: "Test Song 2", artist: "Artist 2")
        ]
        let mockRepository = MockSongRepository(returning: mockSongs)
        let useCase = GetSongsUseCase(repository: mockRepository)

        let songs = try await useCase.execute()

        #expect(songs.count == 2)
        #expect(songs[0].title == "Test Song 1")
        #expect(songs[1].title == "Test Song 2")
    }

    @Test("Execute propagates repository errors")
    func testExecutePropagatesErrors() async {
        let expectedError = NetworkError.noData
        let mockRepository = MockSongRepository(throwing: expectedError)
        let useCase = GetSongsUseCase(repository: mockRepository)

        do {
            _ = try await useCase.execute()
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error as? NetworkError == expectedError)
        }
    }

    @Test("Execute returns empty array when repository returns empty")
    func testExecuteReturnsEmptyArray() async throws {
        let mockRepository = MockSongRepository(returning: [])
        let useCase = GetSongsUseCase(repository: mockRepository)

        let songs = try await useCase.execute()

        #expect(songs.isEmpty)
    }

    @Test("Execute can be called multiple times")
    func testExecuteMultipleTimes() async throws {
        let mockSongs = [Song(id: UUID(), title: "Test", artist: "Artist")]
        let mockRepository = MockSongRepository(returning: mockSongs)
        let useCase = GetSongsUseCase(repository: mockRepository)

        let firstResult = try await useCase.execute()
        let secondResult = try await useCase.execute()

        #expect(firstResult.count == 1)
        #expect(secondResult.count == 1)
    }
}

// MARK: - Mock Repository

private final class MockSongRepository: SongRepositoryProtocol {
    private let result: Result<[Song], Error>

    init(returning songs: [Song]) {
        self.result = .success(songs)
    }

    init(throwing error: Error) {
        self.result = .failure(error)
    }

    func fetchSongs() async throws -> [Song] {
        switch result {
        case .success(let songs):
            return songs
        case .failure(let error):
            throw error
        }
    }

    func createSong(title: String, artist: String) async throws -> Song {
        // Not used in GetSongsUseCase tests, but required by protocol
        return Song(id: UUID(), title: title, artist: artist)
    }
}
