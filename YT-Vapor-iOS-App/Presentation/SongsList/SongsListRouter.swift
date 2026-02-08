import SwiftUI
import SUIRouting

// MARK: - Router Protocol

/// Protocol defining navigation actions from the Songs List
protocol SongsListRouterProtocol {
    /// Navigate to the Add Song screen
    /// - Parameter builder: Builder for creating the Add Song view
    func navigateToAddSong(builder: AddSongBuilder)

    /// Navigate to the Edit Song screen
    /// - Parameter builder: Builder for creating the Edit Song view
    func navigateToEditSong(builder: EditSongBuilder)

    /// Dismiss the current presentation
    func dismiss()
}

// MARK: - Router Implementation

/// Router implementation for Songs List navigation using SUIRouting
///
/// This router:
/// - Uses the SUIRouting library for declarative navigation
/// - Provides methods to trigger navigation actions
/// - Decouples navigation logic from the view and view model
/// - Supports sheet presentation for modal flows
@MainActor
@Observable
final class SongsListRouter: SongsListRouterProtocol {

    // MARK: - Properties

    /// The SUIRouting router instance
    private let router: Router

    // MARK: - Initialization

    /// Creates a new router with the SUIRouting instance
    /// - Parameter router: The SUIRouting router from environment
    init(router: Router) {
        self.router = router
    }

    // MARK: - Navigation Methods

    /// Navigate to the Add Song screen
    /// - Parameter builder: Builder for creating the Add Song view
    func navigateToAddSong(builder: AddSongBuilder) {
        router.showScreen(.sheet) { router in
            builder.build()
        }
    }

    /// Navigate to the Edit Song screen
    /// - Parameter builder: Builder for creating the Edit Song view
    func navigateToEditSong(builder: EditSongBuilder) {
        router.showScreen(.sheet) { router in
            builder.build()
        }
    }

    /// Dismiss the current presentation
    func dismiss() {
        router.dismissScreen()
    }
}
