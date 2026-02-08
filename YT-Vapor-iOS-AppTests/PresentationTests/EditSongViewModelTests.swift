import Testing
import Foundation
@testable import YT_Vapor_iOS_App

/// Tests for EditSongViewModel
@Suite("EditSongViewModel Tests")
@MainActor
struct EditSongViewModelTests {

    // MARK: - Initialization Tests

    @Test("Pre-populates form with song data")
    func testPrePopulation() {
        // Given
        let song = Song(id: UUID(), title: "Original Title", artist: "Original Artist")

        // When
        let viewModel = makeViewModel(song: song)

        // Then
        #expect(viewModel.title == "Original Title")
        #expect(viewModel.artist == "Original Artist")
    }

    @Test("Form is valid when both fields have values")
    func testFormValid() {
        let song = Song(id: UUID(), title: "Title", artist: "Artist")
        let viewModel = makeViewModel(song: song)

        #expect(viewModel.isFormValid)
    }

    @Test("Form is invalid when title is empty")
    func testFormInvalidWhenTitleEmpty() {
        let song = Song(id: UUID(), title: "Title", artist: "Artist")
        let viewModel = makeViewModel(song: song)
        viewModel.title = ""

        #expect(!viewModel.isFormValid)
    }

    @Test("Form is invalid when artist is empty")
    func testFormInvalidWhenArtistEmpty() {
        let song = Song(id: UUID(), title: "Title", artist: "Artist")
        let viewModel = makeViewModel(song: song)
        viewModel.artist = ""

        #expect(!viewModel.isFormValid)
    }

    // MARK: - hasChanges Tests

    @Test("hasChanges is false when form matches original song")
    func testNoChanges() {
        let song = Song(id: UUID(), title: "Title", artist: "Artist")
        let viewModel = makeViewModel(song: song)

        #expect(!viewModel.hasChanges)
    }

    @Test("hasChanges is true when title is changed")
    func testHasChangesWhenTitleChanged() {
        let song = Song(id: UUID(), title: "Title", artist: "Artist")
        let viewModel = makeViewModel(song: song)
        viewModel.title = "New Title"

        #expect(viewModel.hasChanges)
    }

    @Test("hasChanges is true when artist is changed")
    func testHasChangesWhenArtistChanged() {
        let song = Song(id: UUID(), title: "Title", artist: "Artist")
        let viewModel = makeViewModel(song: song)
        viewModel.artist = "New Artist"

        #expect(viewModel.hasChanges)
    }

    // MARK: - Update Tests

    @Test("Successfully updates song and invokes callback")
    func testUpdateSuccess() async {
        // Given
        var callbackInvoked = false
        let song = Song(id: UUID(), title: "Title", artist: "Artist")
        let viewModel = makeViewModel(song: song, onSongUpdated: {
            callbackInvoked = true
        })
        viewModel.title = "Updated Title"

        // When
        let success = await viewModel.updateSong()

        // Then
        #expect(success)
        #expect(callbackInvoked)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Update failure sets error message")
    func testUpdateFailure() async {
        // Given
        let song = Song(id: UUID(), title: "Title", artist: "Artist")
        let viewModel = makeViewModel(song: song, updateShouldFail: true)
        viewModel.title = "Updated Title"

        // When
        let success = await viewModel.updateSong()

        // Then
        #expect(!success)
        #expect(viewModel.errorMessage != nil)
    }

    // MARK: - Delete Tests

    @Test("Successfully deletes song and invokes callback")
    func testDeleteSuccess() async {
        // Given
        var callbackInvoked = false
        let song = Song(id: UUID(), title: "Title", artist: "Artist")
        let viewModel = makeViewModel(song: song, onSongDeleted: {
            callbackInvoked = true
        })

        // When
        let success = await viewModel.deleteSong()

        // Then
        #expect(success)
        #expect(callbackInvoked)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Delete failure sets error message")
    func testDeleteFailure() async {
        // Given
        let song = Song(id: UUID(), title: "Title", artist: "Artist")
        let viewModel = makeViewModel(song: song, deleteShouldFail: true)

        // When
        let success = await viewModel.deleteSong()

        // Then
        #expect(!success)
        #expect(viewModel.errorMessage != nil)
    }

    // MARK: - Helper

    private func makeViewModel(
        song: Song = Song(id: UUID(), title: "Title", artist: "Artist"),
        updateShouldFail: Bool = false,
        deleteShouldFail: Bool = false,
        onSongUpdated: @escaping () async -> Void = {},
        onSongDeleted: @escaping () async -> Void = {}
    ) -> EditSongViewModel {
        EditSongViewModel(
            song: song,
            updateSongUseCase: MockUpdateSongUseCase(shouldFail: updateShouldFail),
            deleteSongUseCase: MockDeleteSongUseCase(shouldFail: deleteShouldFail),
            onSongUpdated: onSongUpdated,
            onSongDeleted: onSongDeleted
        )
    }
}
