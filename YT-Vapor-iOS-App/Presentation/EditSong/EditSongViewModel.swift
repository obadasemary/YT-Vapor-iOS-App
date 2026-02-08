import Foundation
import Observation

/// ViewModel for editing an existing song
///
/// This ViewModel:
/// - Uses @Observable for modern SwiftUI state management
/// - Pre-populates form with existing song data
/// - Manages form input validation
/// - Coordinates with UpdateSongUseCase and DeleteSongUseCase
/// - Handles errors and loading states
@Observable
@MainActor
final class EditSongViewModel {
    private let song: Song
    private let updateSongUseCase: UpdateSongUseCaseProtocol
    private let deleteSongUseCase: DeleteSongUseCaseProtocol
    private let onSongUpdated: () async -> Void
    private let onSongDeleted: () async -> Void

    /// Song title input (pre-populated)
    var title: String

    /// Artist name input (pre-populated)
    var artist: String

    /// Loading state indicator
    var isLoading = false

    /// Controls visibility of the delete confirmation dialog
    var showDeleteConfirmation = false

    /// Error message to display
    var errorMessage: String?

    /// Validates if the form is ready for submission
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !artist.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Whether the form has unsaved changes compared to the original song
    var hasChanges: Bool {
        title.trimmingCharacters(in: .whitespaces) != song.title ||
        artist.trimmingCharacters(in: .whitespaces) != song.artist
    }

    /// Initializes the view model with dependencies
    /// - Parameters:
    ///   - song: The song to edit (provides initial values)
    ///   - updateSongUseCase: The use case for updating songs
    ///   - deleteSongUseCase: The use case for deleting songs
    ///   - onSongUpdated: Async callback when song is successfully updated
    ///   - onSongDeleted: Async callback when song is successfully deleted
    init(
        song: Song,
        updateSongUseCase: UpdateSongUseCaseProtocol,
        deleteSongUseCase: DeleteSongUseCaseProtocol,
        onSongUpdated: @escaping () async -> Void = {},
        onSongDeleted: @escaping () async -> Void = {}
    ) {
        self.song = song
        self.updateSongUseCase = updateSongUseCase
        self.deleteSongUseCase = deleteSongUseCase
        self.onSongUpdated = onSongUpdated
        self.onSongDeleted = onSongDeleted
        self.title = song.title
        self.artist = song.artist
    }

    /// Updates the song with current form values
    /// - Returns: True if song was updated successfully, false otherwise
    func updateSong() async -> Bool {
        errorMessage = nil

        guard isFormValid else {
            errorMessage = "Please fill in all fields"
            return false
        }

        isLoading = true

        do {
            _ = try await updateSongUseCase.execute(
                id: song.id,
                title: title.trimmingCharacters(in: .whitespaces),
                artist: artist.trimmingCharacters(in: .whitespaces)
            )
            isLoading = false
            await onSongUpdated()
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    /// Deletes the current song
    /// - Returns: True if song was deleted successfully, false otherwise
    func deleteSong() async -> Bool {
        errorMessage = nil
        isLoading = true

        do {
            try await deleteSongUseCase.execute(id: song.id)
            isLoading = false
            await onSongDeleted()
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }
}
