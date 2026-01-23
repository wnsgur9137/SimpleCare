//
//  AppCoordinator.swift
//  SimpleCare
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import SwiftUI

import Features
import BasePresentation

final class AppCoordinator: ObservableObject, Coordinator {
    private let diContainer: AppDIContainer
    private var tabCoordinator: TabCoordinator?

    init(diContainer: AppDIContainer) {
        self.diContainer = diContainer
    }

    @ViewBuilder
    func start() -> some View {
        makeTabCoordinator()
    }

    @ViewBuilder
    private func makeTabCoordinator() -> some View {
        let container = diContainer.makeTabDIContainer()
        let coordinator = TabCoordinator(diContainer: container)
        tabCoordinator = coordinator
        return coordinator.start()
    }
}
