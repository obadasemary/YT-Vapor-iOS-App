import Foundation
import Observation

/// ViewModel for adding a new song
///
/// This ViewModel:
/// - Uses @Observable for modern SwiftUI state management
/// - Manages form input validation
/// - Coordinates with CreateSongUseCase to add songs
/// - Handles errors and loading states
@Observable
@MainActor
final class AddSongViewModel {
    private let createSongUseCase: CreateSongUseCaseProtocol
    private let onSongAdded: () async -> Void

    /// Song title input
    var title = ""

    /// Artist name input
    var artist = ""

    /// Loading state indicator
    var isLoading = false

    /// Error message to display
    var errorMessage: String?

    /// Validates if the form is ready for submission
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !artist.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Initializes the view model with dependencies
    /// - Parameters:
    ///   - createSongUseCase: The use case for creating songs
    ///   - onSongAdded: Async callback to invoke when a song is successfully added
    init(createSongUseCase: CreateSongUseCaseProtocol, onSongAdded: @escaping () async -> Void = {}) {
        self.createSongUseCase = createSongUseCase
        self.onSongAdded = onSongAdded
    }
    
    /// Creates a new song with the provided details
    ///
    /// This method:
    /// - Validates input
    /// - Sets loading state
    /// - Executes the create use case
    /// - Handles success and failure
    /// - Returns: True if song was created successfully, false otherwise
    func createSong() async -> Bool {
        // Clear any previous error
        errorMessage = nil
        
        // Validate form
        guard isFormValid else {
            errorMessage = "Please fill in all fields"
            return false
        }
        
        isLoading = true
        
        do {
            let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
            let trimmedArtist = artist.trimmingCharacters(in: .whitespaces)
            
            _ = try await createSongUseCase.execute(title: trimmedTitle, artist: trimmedArtist)

            isLoading = false
            await onSongAdded()
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }
}
