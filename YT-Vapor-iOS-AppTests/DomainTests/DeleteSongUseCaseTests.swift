import Testing
import Foundation
@testable import YT_Vapor_iOS_App

/// Tests for DeleteSongUseCase
@Suite("DeleteSongUseCase Tests")
struct DeleteSongUseCaseTests {

    @Test("Successfully deletes a song")
    func testDeleteSongSuccess() async throws {
        // Given
        let mockRepository = MockSongRepository()
        let useCase = DeleteSongUseCase(repository: mockRepository)
        let songId = UUID()

        // When
        try await useCase.execute(id: songId)

        // Then
        #expect(mockRepository.deleteSongCalled)
        #expect(mockRepository.deletedSongId == songId)
    }

    @Test("Propagates repository errors")
    func testDeleteSongFailure() async {
        // Given
        let mockRepository = MockSongRepository(shouldFail: true)
        let useCase = DeleteSongUseCase(repository: mockRepository)

        // When/Then
        await #expect(throws: (any Error).self) {
            try await useCase.execute(id: UUID())
        }
    }

    // MARK: - Mock Repository

    private final class MockSongRepository: SongRepositoryProtocol {
        var deleteSongCalled = false
        var deletedSongId: UUID?
        private let shouldFail: Bool

        init(shouldFail: Bool = false) {
            self.shouldFail = shouldFail
        }

        func fetchSongs() async throws -> [Song] { [] }

        func createSong(title: String, artist: String) async throws -> Song {
            Song(id: UUID(), title: title, artist: artist)
        }

        func updateSong(id: UUID, title: String, artist: String) async throws -> Song {
            Song(id: id, title: title, artist: artist)
        }

        func deleteSong(id: UUID) async throws {
            if shouldFail {
                throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to delete"])
            }
            deleteSongCalled = true
            deletedSongId = id
        }
    }
}
