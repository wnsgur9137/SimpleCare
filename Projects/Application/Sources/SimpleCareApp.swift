//
//  SimpleCareApp.swift
//  SimpleCare
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import SwiftUI
import BasePresentation

@main
struct SimpleCareApp: App {
    @StateObject private var appCoordinator: AppCoordinator
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var notificationManager = NotificationManager.shared

    init() {
        let diContainer = AppDIContainer()
        _appCoordinator = StateObject(wrappedValue: AppCoordinator(diContainer: diContainer))
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: appCoordinator)
                .preferredColorScheme(themeManager.effectiveColorScheme)
                .task {
                    await notificationManager.checkAuthorizationStatus()
                }
        }
    }
}
