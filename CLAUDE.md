# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

YT-Vapor-iOS-App is a SwiftUI-based iOS application. The project follows standard iOS app architecture with SwiftUI views and modern Swift concurrency patterns.

## Build & Development Commands

### Building
```bash
# Build the project
xcodebuild -scheme YT-Vapor-iOS-App -project YT-Vapor-iOS-App.xcodeproj build

# Build for specific configuration
xcodebuild -scheme YT-Vapor-iOS-App -configuration Debug build
```

### Testing
The project uses **Swift Testing framework** (not XCTest). Test files use `import Testing` and `@Test` macros.

```bash
# Run all tests
xcodebuild test -scheme YT-Vapor-iOS-App -project YT-Vapor-iOS-App.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Run only unit tests (exclude UI tests for speed)
xcodebuild test -scheme YT-Vapor-iOS-App -only-testing:YT-Vapor-iOS-AppTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Run only UI tests
xcodebuild test -scheme YT-Vapor-iOS-App -only-testing:YT-Vapor-iOS-AppUITests -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

### Running the App
Use the xcodebuildmcp or xcodebuildmcp-cli skills for interactive development, debugging, and running the app on simulators or devices.

## Project Structure

```
YT-Vapor-iOS-App/
├── YT-Vapor-iOS-App/           # Main app target
│   ├── YT_Vapor_iOS_AppApp.swift  # App entry point
│   ├── ContentView.swift          # Root view
│   └── Assets.xcassets/           # Asset catalog
├── YT-Vapor-iOS-AppTests/      # Unit tests (Swift Testing)
└── YT-Vapor-iOS-AppUITests/    # UI tests (Swift Testing)
```

## Architecture & Patterns

### SwiftUI Architecture
- App uses SwiftUI declarative UI framework
- Entry point: `YT_Vapor_iOS_AppApp` struct with `@main` attribute
- Views follow SwiftUI view composition patterns

### Testing Strategy
- **Unit tests**: Located in `YT-Vapor-iOS-AppTests/`, use Swift Testing framework
- **UI tests**: Located in `YT-Vapor-iOS-AppUITests/`, use Swift Testing framework
- Write tests using `@Test` macro and `#expect(...)` assertions (not XCTest-style assertions)

## Available Skills

The following specialized skills are installed and should be used when relevant:

- **swiftui-expert-skill**: Use when building SwiftUI features, refactoring views, state management, or adopting modern SwiftUI patterns
- **swift-concurrency**: Use when implementing async/await, actors, tasks, or addressing concurrency issues
- **xcodebuildmcp**: Use for building, testing, running, debugging, and UI automation tasks
- **xcodebuildmcp-cli**: CLI version of XcodeBuildMCP for iOS development workflows

## Swift & iOS Version

- Built with SwiftUI
- Uses modern Swift concurrency patterns (async/await, actors)
- Supports iOS 26+ Liquid Glass design system (when using SwiftUI expert skill)
- Uses Swift Testing framework for all tests
