//
//  OnboardingDIContainer.swift
//  Onboarding
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import BasePresentation
import ProfileDomain
import ProfileData
import OnboardingPresentation

/// 온보딩 DI Container
public final class OnboardingDIContainer: DIContainer, @MainActor OnboardingCoordinatorDependency {
    public struct Dependencies {
        public init() {}
    }

    public let dependencies: Dependencies

    public init(dependencies: Dependencies = Dependencies()) {
        self.dependencies = dependencies
    }

    // MARK: - Repository

    private func makeProfileRepository() -> UserProfileRepositoryProtocol {
        ProfileRepository()
    }

    // MARK: - Use Cases

    private func makeSaveProfileUseCase() -> SaveUserProfileUseCaseProtocol {
        SaveUserProfileUseCase(repository: makeProfileRepository())
    }

    // MARK: - ViewModels

    @MainActor
    public func makeOnboardingViewModel() -> OnboardingViewModel {
        OnboardingViewModel(saveProfileUseCase: makeSaveProfileUseCase())
    }
}
