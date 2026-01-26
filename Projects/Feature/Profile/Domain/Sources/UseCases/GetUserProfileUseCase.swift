//
//  GetUserProfileUseCase.swift
//  ProfileDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// 사용자 프로필 조회 UseCase
public protocol GetUserProfileUseCaseProtocol: Sendable {
    func execute() async throws -> UserProfile?
}

public struct GetUserProfileUseCase: GetUserProfileUseCaseProtocol {
    private let repository: UserProfileRepositoryProtocol

    public init(repository: UserProfileRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> UserProfile? {
        try await repository.getProfile()
    }
}

/// 프로필 저장소 프로토콜 (Domain 레이어)
public protocol UserProfileRepositoryProtocol: Sendable {
    func getProfile() async throws -> UserProfile?
    func saveProfile(_ profile: UserProfile) async throws
    func updateProfile(_ profile: UserProfile) async throws
    func deleteProfile() async throws
}
