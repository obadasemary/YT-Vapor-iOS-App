//
//  YT_Vapor_iOS_AppApp.swift
//  YT-Vapor-iOS-App
//
//  Created by Abdelrahman Mohamed on 07.02.2026.
//

import SwiftUI
import SUIRouting

@main
struct YT_Vapor_iOS_AppApp: App {
    /// Dependency injection container for the application
    private let container = AppDependencyContainer()

    var body: some Scene {
        WindowGroup {
            RouterView { router in
                SongsListBuilder(container: container).build(router: router)
            }
        }
    }
}
