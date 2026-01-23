//
//  TabCoordinator.swift
//  Features
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import SwiftUI

import Splash
import Onboarding
import Home
import Settings
import BasePresentation

public final class TabCoordinator: ObservableObject, Coordinator {
    private let diContainer: TabDIContainer

    @Published public var selectedTab: AppTab = .home
    @Published public var isSplashCompleted: Bool = false

    public init(diContainer: TabDIContainer) {
        self.diContainer = diContainer
    }

    @ViewBuilder
    public func start() -> some View {
        TabCoordinatorView(coordinator: self)
    }

    @ViewBuilder
    func makeSplash() -> some View {}

    @ViewBuilder
    func makeOnboarding() -> some View {}

    @ViewBuilder
    public func makeSettings() -> some View {}

    private func completeSplash() {
        withAnimation {
            isSplashCompleted = true
            selectedTab = .home
        }
    }

    private func completeOnboarding() {
        withAnimation {
            selectedTab = .home
        }
    }
}
