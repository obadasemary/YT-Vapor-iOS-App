import SwiftUI

/// View for adding a new song
///
/// This view:
/// - Provides a form to input song details (title and artist)
/// - Validates input before submission
/// - Shows loading state during creation
/// - Handles errors gracefully
/// - Dismisses automatically on success
struct AddSongView: View {
    @State private var viewModel: AddSongViewModel
    @Environment(\.dismiss) private var dismiss
    
    /// Initializes the view with a view model
    /// - Parameter viewModel: The view model managing the add song state
    init(viewModel: AddSongViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Song Title", text: $viewModel.title)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                    
                    TextField("Artist Name", text: $viewModel.artist)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                } header: {
                    Text("Song Details")
                } footer: {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Add New Song")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(viewModel.isLoading)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            let success = await viewModel.createSong()
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    .bold()
                }
            }
            .disabled(viewModel.isLoading)
            .overlay {
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.2)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                            )
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Empty Form") {
    let mockRepository = MockSongRepository()
    let useCase = CreateSongUseCase(repository: mockRepository)
    let viewModel = AddSongViewModel(createSongUseCase: useCase)
    
    return AddSongView(viewModel: viewModel)
}

#Preview("Pre-filled Form") {
    let mockRepository = MockSongRepository()
    let useCase = CreateSongUseCase(repository: mockRepository)
    let viewModel = AddSongViewModel(createSongUseCase: useCase)
    viewModel.title = "Bohemian Rhapsody"
    viewModel.artist = "Queen"
    
    return AddSongView(viewModel: viewModel)
}

// MARK: - Mock Repository for Preview

private final class MockSongRepository: SongRepositoryProtocol {
    func fetchSongs() async throws -> [Song] { [] }

    func createSong(title: String, artist: String) async throws -> Song {
        try await Task.sleep(for: .seconds(1))
        return Song(id: UUID(), title: title, artist: artist)
    }

    func updateSong(id: UUID, title: String, artist: String) async throws -> Song {
        Song(id: id, title: title, artist: artist)
    }

    func deleteSong(id: UUID) async throws {}
}
