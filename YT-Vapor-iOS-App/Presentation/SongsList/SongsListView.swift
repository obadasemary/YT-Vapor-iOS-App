import SwiftUI
import SUIRouting

/// Main view for displaying the list of songs
///
/// This view:
/// - Uses modern SwiftUI patterns (@Observable, .task, NavigationStack)
/// - Displays different states (loading, loaded, error, empty)
/// - Features card-style design with smooth animations
/// - Shows skeleton loading for better UX
/// - Implements pull-to-refresh
struct SongsListView: View {
    @State private var viewModel: SongsListViewModel

    private let addSongBuilder: AddSongBuilder

    /// Initializes the view with a view model
    /// - Parameters:
    ///   - viewModel: The view model managing the songs state
    ///   - addSongBuilder: Builder for creating the Add Song view (used by router)
    init(viewModel: SongsListViewModel, addSongBuilder: AddSongBuilder) {
        _viewModel = State(initialValue: viewModel)
        self.addSongBuilder = addSongBuilder
    }

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Songs")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            viewModel.navigateToAddSong()
                        } label: {
                            Image(systemName: "plus")
                                .fontWeight(.semibold)
                        }
                    }
                }
        }
        .task {
            await viewModel.loadSongs()
        }
        .alert(
            "Delete Song",
            isPresented: Binding(
                get: { viewModel.songPendingDeletion != nil },
                set: { if !$0 { viewModel.songPendingDeletion = nil } }
            ),
            presenting: viewModel.songPendingDeletion
        ) { song in
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteSong(song)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: { song in
            Text("Are you sure you want to delete \"\(song.title)\"? This action cannot be undone.")
        }
    }

    // MARK: - Content View

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .idle:
            Color(.systemGroupedBackground).ignoresSafeArea()

        case .loading:
            loadingView

        case .loaded(let songs):
            if songs.isEmpty {
                EmptyStateView()
            } else {
                songsListView(songs: songs)
            }

        case .error(let error):
            errorView(error: error)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { _ in
                    SongRowSkeletonView()
                }
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Songs List View

    private func songsListView(songs: [Song]) -> some View {
        List {
            ForEach(songs) { song in
                SongRowView(song: song)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        viewModel.navigateToEditSong(song)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.confirmDeleteSong(song)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .background(Color(.systemGroupedBackground))
        .refreshable {
            await viewModel.refreshSongs()
        }
    }

    // MARK: - Error View

    private func errorView(error: Error) -> some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer()
                    .frame(height: 60)

                // Error icon with gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.red.opacity(0.1), .orange.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.red, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                // Error message
                VStack(spacing: 12) {
                    Text("Failed to Load Songs")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // Retry button
                Button {
                    Task {
                        await viewModel.loadSongs()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: Capsule()
                    )
                    .shadow(
                        color: .blue.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}

// MARK: - Preview

#Preview("Loaded State") {
    RouterView { router in
        let container = AppDependencyContainer()
        return SongsListBuilder(container: container).build(router: router)
    }
}

#Preview("Loading State") {
    RouterView { router in
        let container = AppDependencyContainer()
        return SongsListBuilder(container: container).build(router: router)
    }
}

#Preview("Empty State") {
    RouterView { router in
        let container = AppDependencyContainer()
        return SongsListBuilder(container: container).build(router: router)
    }
}

#Preview("Error State") {
    RouterView { router in
        let container = AppDependencyContainer()
        return SongsListBuilder(container: container).build(router: router)
    }
}

// MARK: - Mock Repository for Preview

private final class MockSongRepository: SongRepositoryProtocol {
    private let songs: [Song]
    private let shouldFail: Bool
    private let shouldDelay: Bool

    init(
        songs: [Song] = [
            Song(id: UUID(), title: "Bohemian Rhapsody", artist: "Queen"),
            Song(id: UUID(), title: "Stairway to Heaven", artist: "Led Zeppelin"),
            Song(id: UUID(), title: "Hotel California", artist: "Eagles"),
            Song(id: UUID(), title: "Imagine", artist: "John Lennon"),
            Song(id: UUID(), title: "Sweet Child O' Mine", artist: "Guns N' Roses")
        ],
        shouldFail: Bool = false,
        shouldDelay: Bool = false
    ) {
        self.songs = songs
        self.shouldFail = shouldFail
        self.shouldDelay = shouldDelay
    }

    func fetchSongs() async throws -> [Song] {
        if shouldDelay {
            try await Task.sleep(for: .seconds(10))
        }

        if shouldFail {
            throw NSError(
                domain: "MockError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to load songs from server"]
            )
        }

        return songs
    }
    
    func createSong(title: String, artist: String) async throws -> Song {
        try await Task.sleep(for: .seconds(1))
        return Song(id: UUID(), title: title, artist: artist)
    }

    func updateSong(id: UUID, title: String, artist: String) async throws -> Song {
        try await Task.sleep(for: .seconds(1))
        return Song(id: id, title: title, artist: artist)
    }

    func deleteSong(id: UUID) async throws {
        try await Task.sleep(for: .seconds(1))
    }
}

