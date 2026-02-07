# Navigation Architecture - Builder + Router Pattern

## Overview

This document describes the navigation architecture implemented using the **Builder + Router pattern** inspired by Clean Architecture principles and integrated with the **SUIRouting** library.

## Architecture Components

### 1. Router Pattern

**Purpose**: Decouple navigation logic from Views and ViewModels

**Components**:

#### Router Protocol (`SongsListRouterProtocol`)
```swift
protocol SongsListRouterProtocol {
    func navigateToAddSong(builder: AddSongBuilder)
    func dismiss()
}
```

#### Router Implementation (`SongsListRouter`)
- Uses SUIRouting library for declarative navigation
- Wraps `Router` from SUIRouting
- Provides type-safe navigation methods
- Handles sheet, fullscreen, and push navigation

**Example**:
```swift
final class SongsListRouter: SongsListRouterProtocol {
    private let router: Router

    func navigateToAddSong(builder: AddSongBuilder) {
        router.showScreen(.sheet) { _ in
            builder.build()
        }
    }
}
```

### 2. Builder Pattern

**Purpose**: Compose views with their dependencies using dependency injection

**Components**:

#### SongsListBuilder
- Creates `SongsListView` with all dependencies
- Injects router, use cases, and child builders
- Receives `Router` from environment (provided by `RouterView`)

**Example**:
```swift
final class SongsListBuilder {
    private let container: AppDependencyContainer

    func build(router: Router) -> SongsListView {
        let songsListRouter = SongsListRouter(router: router)
        let addSongBuilder = AddSongBuilder(container: container, songsListRouter: songsListRouter)
        let viewModel = container.makeSongsListViewModel(
            router: songsListRouter,
            addSongBuilder: addSongBuilder
        )
        return SongsListView(viewModel: viewModel, addSongBuilder: addSongBuilder)
    }
}
```

#### AddSongBuilder
- Creates `AddSongView` with dependencies
- Receives parent router to enable dismissal
- Connects onSongAdded callback to router.dismiss()

### 3. SUIRouting Integration

**Library**: [SUIRouting](https://github.com/obadasemary/SUIRouting) (v1.0.7)

**Usage**:

#### App Entry Point
```swift
@main
struct YT_Vapor_iOS_AppApp: App {
    private let container = AppDependencyContainer()

    var body: some Scene {
        WindowGroup {
            RouterView { router in
                SongsListBuilder(container: container).build(router: router)
            }
        }
    }
}
```

#### Navigation Types Supported
- `.sheet` - Modal sheet presentation
- `.fullScreenCover` - Full-screen modal
- `.push` - Navigation stack push
- Alert and custom modals

## Data Flow

### Navigation Flow: Songs List → Add Song

```
1. User Action (tap + button)
   ↓
2. View calls ViewModel
   SongsListView → viewModel.navigateToAddSong()
   ↓
3. ViewModel delegates to Router
   SongsListViewModel → router.navigateToAddSong(builder: addSongBuilder)
   ↓
4. Router uses SUIRouting
   SongsListRouter → router.showScreen(.sheet) { builder.build() }
   ↓
5. Builder creates View
   AddSongBuilder → AddSongView(viewModel: ...)
   ↓
6. View is presented as sheet
```

### Dismissal Flow

```
1. AddSongViewModel.createSong() succeeds
   ↓
2. onSongAdded callback is triggered
   AddSongViewModel → onSongAdded()
   ↓
3. Callback dismisses via router
   AddSongBuilder closure → songsListRouter.dismiss()
   ↓
4. SUIRouting dismisses sheet
   SongsListRouter → router.dismissScreen()
   ↓
5. SongsListView reappears and reloads
   .onAppear → viewModel.loadSongs()
```

## Benefits of This Architecture

### 1. Separation of Concerns
- **Views**: Stateless, declarative UI only
- **ViewModels**: Business logic coordination, no navigation details
- **Routers**: Navigation logic encapsulation
- **Builders**: Dependency injection composition

### 2. Testability
- **Protocol-based routers**: Easy to mock in tests
- **Builders**: Can create test instances with fake dependencies
- **No hardcoded navigation**: ViewModels test without UI concerns

Example test:
```swift
let mockRouter = MockSongsListRouter()
let viewModel = SongsListViewModel(..., router: mockRouter)
viewModel.navigateToAddSong()
#expect(mockRouter.navigateToAddSongCalled)
```

### 3. Maintainability
- Navigation changes isolated to Router classes
- View composition centralized in Builders
- Clear dependency graph

### 4. Flexibility
- Easy to swap navigation styles (sheet ↔ push ↔ fullscreen)
- Can replace SUIRouting with other libraries
- Builder pattern allows different configurations per context

## Files Created/Modified

### New Files
- [Presentation/SongsList/SongsListRouter.swift](YT-Vapor-iOS-App/Presentation/SongsList/SongsListRouter.swift)
- [Presentation/SongsList/SongsListBuilder.swift](YT-Vapor-iOS-App/Presentation/SongsList/SongsListBuilder.swift)
- [Presentation/AddSong/AddSongBuilder.swift](YT-Vapor-iOS-App/Presentation/AddSong/AddSongBuilder.swift)

### Modified Files
- [YT_Vapor_iOS_AppApp.swift](YT-Vapor-iOS-App/YT_Vapor_iOS_AppApp.swift) - Added RouterView
- [Presentation/SongsList/SongsListViewModel.swift](YT-Vapor-iOS-App/Presentation/SongsList/SongsListViewModel.swift) - Added router dependency
- [Presentation/SongsList/SongsListView.swift](YT-Vapor-iOS-App/Presentation/SongsList/SongsListView.swift) - Removed manual sheet handling
- [Presentation/AddSong/AddSongViewModel.swift](YT-Vapor-iOS-App/Presentation/AddSong/AddSongViewModel.swift) - Added onSongAdded callback
- [DI/AppDependencyContainer.swift](YT-Vapor-iOS-App/DI/AppDependencyContainer.swift) - Updated factory methods
- All test files updated for new router pattern

## Testing

All tests passing: **24 tests passed**

Test coverage includes:
- ViewModel navigation triggering router methods
- State management independent of navigation
- Builder dependency injection
- Mock routers for testing

## Future Enhancements

1. **Deep Linking**: Add URL-based routing
2. **Navigation State Restoration**: Persist and restore navigation state
3. **Nested Navigation**: Support tab bars and nested stacks
4. **Analytics**: Add navigation tracking hooks
5. **Coordinator Pattern**: Extract complex navigation flows to Coordinators

## References

- [ARCHITECTURE.md](ARCHITECTURE.md) - Full Clean Architecture documentation
- [CLAUDE.md](CLAUDE.md) - Project setup and guidelines
- [SUIRouting GitHub](https://github.com/obadasemary/SUIRouting) - Navigation library
