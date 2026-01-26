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
public final class ProfileDIContainer: DIContainer, ProfileCoordinatorDependency {
    public struct Dependencies {
        public init() {}
    }

    public let dependencies: Dependencies

    public init(dependencies: Dependencies = Dependencies()) {
        self.dependencies = dependencies
    }

    // MARK: - Repository

    private func makeRepository() -> UserProfileRepositoryProtocol {
        ProfileRepository()
    }

    // MARK: - Use Cases

    private func makeGetProfileUseCase() -> GetUserProfileUseCaseProtocol {
        GetUserProfileUseCase(repository: makeRepository())
    }

    private func makeSaveProfileUseCase() -> SaveUserProfileUseCaseProtocol {
        SaveUserProfileUseCase(repository: makeRepository())
    }

    private func makeUpdateProfileUseCase() -> UpdateUserProfileUseCaseProtocol {
        UpdateUserProfileUseCase(repository: makeRepository())
    }

    // MARK: - TCA Dependencies

    public var profileClient: ProfileClient {
        let getUseCase = makeGetProfileUseCase()
        let saveUseCase = makeSaveProfileUseCase()
        let updateUseCase = makeUpdateProfileUseCase()

        return ProfileClient(
            getProfile: {
                try await getUseCase.execute()
            },
            saveProfile: { profile in
                try await saveUseCase.execute(profile: profile)
            },
            updateProfile: { profile in
                try await updateUseCase.execute(profile: profile)
            }
        )
    }
}
