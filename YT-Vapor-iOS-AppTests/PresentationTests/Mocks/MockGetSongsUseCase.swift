import Foundation
@testable import YT_Vapor_iOS_App

/// Mock implementation of GetSongsUseCase for testing
///
/// This mock allows tests to inject pre-configured responses
/// without depending on actual repository or network layer.
final class MockGetSongsUseCase: GetSongsUseCaseProtocol {
    private let result: Result<[Song], Error>

    /// Initializes with a success result
    /// - Parameter songs: The songs to return on execute
    init(returning songs: [Song]) {
        self.result = .success(songs)
    }

    /// Initializes with an error result
    /// - Parameter error: The error to throw on execute
    init(throwing error: Error) {
        self.result = .failure(error)
    }

    /// Mocked execute implementation
    func execute() async throws -> [Song] {
        switch result {
        case .success(let songs):
            return songs
        case .failure(let error):
            throw error
        }
    }
}

/// Mock implementation of CreateSongUseCase for testing
///
/// This mock allows tests to inject pre-configured responses
/// without depending on actual repository or network layer.
final class MockCreateSongUseCase: CreateSongUseCaseProtocol {
    var executeCalled = false
    var shouldFail = false
    private let delay: TimeInterval
    
    /// Initializes the mock with optional configuration
    /// - Parameters:
    ///   - shouldFail: Whether to throw an error
    ///   - delay: Optional delay to simulate network latency
    init(shouldFail: Bool = false, delay: TimeInterval = 0) {
        self.shouldFail = shouldFail
        self.delay = delay
    }
    
    /// Mocked execute implementation
    func execute(title: String, artist: String) async throws -> Song {
        executeCalled = true
        
        if delay > 0 {
            try await Task.sleep(for: .seconds(delay))
        }
        
        if shouldFail {
            throw NSError(
                domain: "MockError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create song"]
            )
        }
        
        return Song(id: UUID(), title: title, artist: artist)
    }
}
