import SwiftUI

/// View for editing an existing song
///
/// This view:
/// - Provides a form to edit song details (pre-populated with existing data)
/// - Validates input before submission
/// - Shows loading state during update/delete
/// - Includes a delete button with confirmation dialog
/// - Handles errors gracefully
/// - Dismisses automatically on success
struct EditSongView: View {
    @State private var viewModel: EditSongViewModel
    @Environment(\.dismiss) private var dismiss

    /// Initializes the view with a view model
    /// - Parameter viewModel: The view model managing the edit song state
    init(viewModel: EditSongViewModel) {
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

                Section {
                    Button(role: .destructive) {
                        viewModel.showDeleteConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Song")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Song")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(viewModel.isLoading)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            let success = await viewModel.updateSong()
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoading || !viewModel.hasChanges)
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
            .alert("Delete Song", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    Task {
                        let success = await viewModel.deleteSong()
                        if success {
                            dismiss()
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this song? This action cannot be undone.")
            }
        }
    }
}

// MARK: - Preview

#Preview("Edit Song") {
    let song = Song(id: UUID(), title: "Bohemian Rhapsody", artist: "Queen")
    let mockRepository = PreviewMockSongRepository()
    let updateUseCase = UpdateSongUseCase(repository: mockRepository)
    let deleteUseCase = DeleteSongUseCase(repository: mockRepository)
    let viewModel = EditSongViewModel(
        song: song,
        updateSongUseCase: updateUseCase,
        deleteSongUseCase: deleteUseCase
    )

    return EditSongView(viewModel: viewModel)
}

// MARK: - Mock Repository for Preview

private final class PreviewMockSongRepository: SongRepositoryProtocol {
    func fetchSongs() async throws -> [Song] { [] }

    func createSong(title: String, artist: String) async throws -> Song {
        Song(id: UUID(), title: title, artist: artist)
    }

    func updateSong(id: UUID, title: String, artist: String) async throws -> Song {
        try await Task.sleep(for: .seconds(1))
        return Song(id: id, title: title, artist: artist)
    }

    func deleteSong(id: UUID) async throws {
        try await Task.sleep(for: .seconds(1))
    }
}
