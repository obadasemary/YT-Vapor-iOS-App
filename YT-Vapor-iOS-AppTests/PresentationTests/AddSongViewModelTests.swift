import Testing
import Foundation
@testable import YT_Vapor_iOS_App

/// Tests for AddSongViewModel
///
/// These tests verify:
/// - Form validation
/// - Song creation flow
/// - Loading states
/// - Error handling
@Suite("AddSongViewModel Tests")
@MainActor
struct AddSongViewModelTests {
    
    // MARK: - Form Validation Tests
    
    @Test("Form is invalid when both fields are empty")
    func testFormInvalidWhenEmpty() {
        // Given
        let mockUseCase = MockCreateSongUseCase()
        let viewModel = AddSongViewModel(createSongUseCase: mockUseCase)
        
        // Then
        #expect(!viewModel.isFormValid)
    }
    
    @Test("Form is invalid when title is empty")
    func testFormInvalidWhenTitleEmpty() {
        // Given
        let mockUseCase = MockCreateSongUseCase()
        let viewModel = AddSongViewModel(createSongUseCase: mockUseCase)
        
        // When
        viewModel.artist = "Queen"
        
        // Then
        #expect(!viewModel.isFormValid)
    }
    
    @Test("Form is invalid when artist is empty")
    func testFormInvalidWhenArtistEmpty() {
        // Given
        let mockUseCase = MockCreateSongUseCase()
        let viewModel = AddSongViewModel(createSongUseCase: mockUseCase)
        
        // When
        viewModel.title = "Bohemian Rhapsody"
        
        // Then
        #expect(!viewModel.isFormValid)
    }
    
    @Test("Form is invalid when title is only whitespace")
    func testFormInvalidWhenTitleWhitespace() {
        // Given
        let mockUseCase = MockCreateSongUseCase()
        let viewModel = AddSongViewModel(createSongUseCase: mockUseCase)
        
        // When
        viewModel.title = "   "
        viewModel.artist = "Queen"
        
        // Then
        #expect(!viewModel.isFormValid)
    }
    
    @Test("Form is valid when both fields have values")
    func testFormValidWhenBothFieldsFilled() {
        // Given
        let mockUseCase = MockCreateSongUseCase()
        let viewModel = AddSongViewModel(createSongUseCase: mockUseCase)
        
        // When
        viewModel.title = "Bohemian Rhapsody"
        viewModel.artist = "Queen"
        
        // Then
        #expect(viewModel.isFormValid)
    }
    
    // MARK: - Create Song Tests
    
    @Test("Successfully creates song")
    func testCreateSongSuccess() async {
        // Given
        var callbackInvoked = false
        let mockUseCase = MockCreateSongUseCase()
        let viewModel = AddSongViewModel(createSongUseCase: mockUseCase, onSongAdded: {
            callbackInvoked = true
        })
        viewModel.title = "Bohemian Rhapsody"
        viewModel.artist = "Queen"

        // When
        let success = await viewModel.createSong()

        // Then
        #expect(success)
        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
        #expect(mockUseCase.executeCalled)
        #expect(callbackInvoked)
    }
    
    @Test("Sets loading state during creation")
    func testLoadingStateDuringCreation() async {
        // Given
        let mockUseCase = MockCreateSongUseCase(delay: 0.5)
        let viewModel = AddSongViewModel(createSongUseCase: mockUseCase)
        viewModel.title = "Bohemian Rhapsody"
        viewModel.artist = "Queen"
        
        // When
        Task {
            await viewModel.createSong()
        }
        
        // Brief delay to allow loading state to be set
        try? await Task.sleep(for: .milliseconds(100))
        
        // Then
        #expect(viewModel.isLoading)
    }
    
    @Test("Returns false and sets error message on failure")
    func testCreateSongFailure() async {
        // Given
        let mockUseCase = MockCreateSongUseCase(shouldFail: true)
        let viewModel = AddSongViewModel(createSongUseCase: mockUseCase)
        viewModel.title = "Bohemian Rhapsody"
        viewModel.artist = "Queen"
        
        // When
        let success = await viewModel.createSong()
        
        // Then
        #expect(!success)
        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage != nil)
        #expect(mockUseCase.executeCalled)
    }
    
    @Test("Returns false when form is invalid")
    func testCreateSongWithInvalidForm() async {
        // Given
        let mockUseCase = MockCreateSongUseCase()
        let viewModel = AddSongViewModel(createSongUseCase: mockUseCase)
        // Leave fields empty
        
        // When
        let success = await viewModel.createSong()
        
        // Then
        #expect(!success)
        #expect(viewModel.errorMessage == "Please fill in all fields")
        #expect(!mockUseCase.executeCalled)
    }
    
    @Test("Clears error message on new attempt")
    func testClearsErrorOnNewAttempt() async {
        // Given
        let mockUseCase = MockCreateSongUseCase(shouldFail: true)
        let viewModel = AddSongViewModel(createSongUseCase: mockUseCase)
        viewModel.title = "Bohemian Rhapsody"
        viewModel.artist = "Queen"
        
        // First attempt (fails)
        _ = await viewModel.createSong()
        #expect(viewModel.errorMessage != nil)
        
        // When - Second attempt
        mockUseCase.shouldFail = false
        _ = await viewModel.createSong()
        
        // Then - Error should be cleared
        #expect(viewModel.errorMessage == nil)
    }
}
