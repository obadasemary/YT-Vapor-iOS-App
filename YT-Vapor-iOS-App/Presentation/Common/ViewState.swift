import Foundation

/// Generic view state for managing asynchronous operations
///
/// This enum provides a type-safe way to represent the different states
/// a view can be in while loading data asynchronously.
///
/// Usage:
/// ```
/// var state: ViewState<[Song]> = .idle
/// ```
enum ViewState<T> {
    /// Initial state before any operation has started
    case idle

    /// Loading state while the operation is in progress
    case loading

    /// Success state with the loaded data
    case loaded(T)

    /// Error state with the error that occurred
    case error(Error)

    /// Convenience property to check if currently loading
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    /// Convenience property to get the loaded data if available
    var data: T? {
        if case .loaded(let data) = self {
            return data
        }
        return nil
    }

    /// Convenience property to get the error if available
    var error: Error? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }
}
