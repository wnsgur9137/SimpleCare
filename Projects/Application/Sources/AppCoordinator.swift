//
//  AppCoordinator.swift
//  SimpleCare
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import SwiftUI

import Tab
import Splash
import Onboarding
import BasePresentation

final class AppCoordinator: ObservableObject {
    private let diContainer: AppDIContainer

    private enum UserDefaultsKeys {
        static let isOnboardingCompleted = "com.simplecare.isOnboardingCompleted"
    }

    // MARK: - Child Coordinators

    private var splashCoordinator: SplashCoordinator?
    private var onboardingCoordinator: OnboardingCoordinator?
    private var tabCoordinator: TabCoordinator?

    // MARK: - Published Properties

    @Published var isSplashCompleted: Bool = false
    @Published var isOnboardingCompleted: Bool = false

    init(diContainer: AppDIContainer) {
        self.diContainer = diContainer
        self.isOnboardingCompleted = UserDefaults.standard.bool(
            forKey: UserDefaultsKeys.isOnboardingCompleted
        )
    }

    // MARK: - Splash

    @MainActor
    func makeSplash() -> some View {
        let container = diContainer.makeSplashDIContainer()
        let coordinator = SplashCoordinator(dependencies: container) { [weak self] in
            self?.completeSplash()
        }
        self.splashCoordinator = coordinator
        return coordinator.start()
    }

    // MARK: - Onboarding

    @MainActor
    func makeOnboarding() -> some View {
        let container = diContainer.makeOnboardingDIContainer()
        let coordinator = OnboardingCoordinator(dependencies: container) { [weak self] in
            self?.completeOnboarding()
        }
        self.onboardingCoordinator = coordinator
        return coordinator.start()
    }

    // MARK: - Tab

    @MainActor
    func makeTabCoordinator() -> some View {
        let container = diContainer.makeTabDIContainer()
        let coordinator = TabCoordinator(diContainer: container)
        self.tabCoordinator = coordinator
        return coordinator.start()
    }

    // MARK: - Private

    private func completeSplash() {
        withAnimation {
            isSplashCompleted = true
            splashCoordinator = nil
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isOnboardingCompleted)
        withAnimation {
            isOnboardingCompleted = true
            onboardingCoordinator = nil
        }
    }
}
