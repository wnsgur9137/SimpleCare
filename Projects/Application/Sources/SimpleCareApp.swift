//
//  SimpleCareApp.swift
//  SimpleCare
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import SwiftUI

@main
struct SimpleCareApp: App {
    @StateObject private var appCoordinator: AppCoordinator

    init() {
        let diContainer = AppDIContainer()
        _appCoordinator = StateObject(wrappedValue: AppCoordinator(diContainer: diContainer))
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: appCoordinator)
        }
    }
}
