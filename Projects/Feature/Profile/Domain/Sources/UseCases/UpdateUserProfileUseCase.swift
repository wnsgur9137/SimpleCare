//
//  UpdateUserProfileUseCase.swift
//  ProfileDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// 사용자 프로필 업데이트 UseCase
public protocol UpdateUserProfileUseCaseProtocol: Sendable {
    func execute(profile: UserProfile) async throws
}

public struct UpdateUserProfileUseCase: UpdateUserProfileUseCaseProtocol {
    private let repository: UserProfileRepositoryProtocol

    public init(repository: UserProfileRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(profile: UserProfile) async throws {
        var updatedProfile = profile
        updatedProfile.updatedAt = Date()
        try await repository.updateProfile(updatedProfile)
    }
}
