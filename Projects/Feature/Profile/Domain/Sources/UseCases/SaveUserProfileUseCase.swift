//
//  SaveUserProfileUseCase.swift
//  ProfileDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// 사용자 프로필 저장 UseCase
public protocol SaveUserProfileUseCaseProtocol: Sendable {
    func execute(profile: UserProfile) async throws
}

public struct SaveUserProfileUseCase: SaveUserProfileUseCaseProtocol {
    private let repository: UserProfileRepositoryProtocol

    public init(repository: UserProfileRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(profile: UserProfile) async throws {
        try await repository.saveProfile(profile)
    }
}
