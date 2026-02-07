import SwiftUI

/// A skeleton loading view that mimics the SongRowView structure
///
/// Used to provide visual feedback while songs are loading,
/// improving perceived performance and user experience.
struct SongRowSkeletonView: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 16) {
            // Skeleton circle (music icon placeholder)
            Circle()
                .fill(.gray.opacity(0.3))
                .frame(width: 56, height: 56)
                .shimmer(isAnimating: isAnimating)

            // Skeleton text lines
            VStack(alignment: .leading, spacing: 8) {
                // Title placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray.opacity(0.3))
                    .frame(height: 16)
                    .frame(maxWidth: .infinity)
                    .shimmer(isAnimating: isAnimating)

                // Artist placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray.opacity(0.3))
                    .frame(height: 14)
                    .frame(maxWidth: 120)
                    .shimmer(isAnimating: isAnimating)
            }

            Spacer()
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
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Shimmer Effect

extension View {
    /// Applies a shimmer animation effect to the view
    /// - Parameter isAnimating: Whether the shimmer should be animating
    /// - Returns: A view with shimmer effect applied
    @ViewBuilder
    func shimmer(isAnimating: Bool) -> some View {
        self.modifier(ShimmerModifier(isAnimating: isAnimating))
    }
}

struct ShimmerModifier: ViewModifier {
    let isAnimating: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.5),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width)
                    .offset(x: phase * geometry.size.width)
                    .mask(content)
                }
            )
            .onAppear {
                if isAnimating {
                    withAnimation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 1
                    }
                }
            }
    }
}

// MARK: - Preview

#Preview("Skeleton Loading") {
    ScrollView {
        VStack(spacing: 0) {
            ForEach(0..<5, id: \.self) { _ in
                SongRowSkeletonView()
            }
        }
    }
    .background(.gray.opacity(0.1))
}
