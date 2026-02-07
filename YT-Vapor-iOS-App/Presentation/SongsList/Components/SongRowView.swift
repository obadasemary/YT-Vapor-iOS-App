import SwiftUI

/// A reusable row component for displaying a single song
///
/// Features:
/// - Card-style design with shadow and rounded corners
/// - Visual hierarchy with typography
/// - Music icon for better visual appeal
/// - Tap animation feedback
struct SongRowView: View {
    let song: Song

    var body: some View {
        HStack(spacing: 16) {
            // Music icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: "music.note")
                    .font(.title2)
                    .foregroundStyle(.white)
            }

            // Song information
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(song.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Chevron indicator
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(
                    color: .black.opacity(0.05),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

// MARK: - Preview

#Preview("Song Row") {
    VStack(spacing: 12) {
        SongRowView(
            song: Song(
                id: UUID(),
                title: "Bohemian Rhapsody",
                artist: "Queen"
            )
        )

        SongRowView(
            song: Song(
                id: UUID(),
                title: "Stairway to Heaven",
                artist: "Led Zeppelin"
            )
        )

        SongRowView(
            song: Song(
                id: UUID(),
                title: "Hotel California",
                artist: "Eagles"
            )
        )
    }
    .background(.gray.opacity(0.1))
}
