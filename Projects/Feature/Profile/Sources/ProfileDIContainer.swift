//
//  ProfileDIContainer.swift
//  Profile
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import BasePresentation
import ProfileDomain
import ProfileData
import ProfilePresentation

/// 프로필 DI Container
public final class ProfileDIContainer: DIContainer, @MainActor ProfileCoordinatorDependency {
    public struct Dependencies {
        public init() {}
    }

    public let dependencies: Dependencies

    public init(dependencies: Dependencies = Dependencies()) {
        self.dependencies = dependencies
    }

    // MARK: - Repository

    private func makeRepository() -> UserProfileRepositoryProtocol {
        return ProfileRepository()
    }

    // MARK: - Use Cases

    private func makeGetProfileUseCase() -> GetUserProfileUseCaseProtocol {
        return GetUserProfileUseCase(repository: makeRepository())
    }

    private func makeSaveProfileUseCase() -> SaveUserProfileUseCaseProtocol {
        return SaveUserProfileUseCase(repository: makeRepository())
    }

    private func makeUpdateProfileUseCase() -> UpdateUserProfileUseCaseProtocol {
        return UpdateUserProfileUseCase(repository: makeRepository())
    }

    // MARK: - ViewModels

    @MainActor
    public func makeProfileViewModel() -> ProfileViewModel {
        return ProfileViewModel(
            getProfileUseCase: makeGetProfileUseCase(),
            saveProfileUseCase: makeSaveProfileUseCase(),
            updateProfileUseCase: makeUpdateProfileUseCase()
        )
    }
}
