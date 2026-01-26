//
//  AppDIContainer.swift
//  SimpleCare
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import Foundation

import Features
import Splash
import Onboarding
import BasePresentation

final class AppDIContainer: DIContainer {
    struct Dependencies {}

    let dependencies: Dependencies

    init(dependencies: Dependencies = Dependencies()) { // TODO: - AppConfiguration 생성
        self.dependencies = dependencies
    }

    // MARK: - Splash DIContainer

    func makeSplashDIContainer() -> SplashDIContainer {
        SplashDIContainer(minimumDuration: 1.5)
    }

    // MARK: - Onboarding DIContainer

    func makeOnboardingDIContainer() -> OnboardingDIContainer {
        OnboardingDIContainer()
    }

    // MARK: - Tab DIContainer

    func makeTabDIContainer() -> TabDIContainer {
        let dependencies = TabDIContainer.Dependencies()
        return TabDIContainer(dependencies: dependencies)
    }
}
