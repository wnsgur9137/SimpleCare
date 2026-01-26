//
//  UserProfileStorage.swift
//  StorageInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import SwiftData

/// 사용자 프로필 스토리지 프로토콜 (Infrastructure 레이어)
public protocol UserProfileStorageProtocol: Sendable {
    func fetchProfile() async throws -> UserProfileModel?
    func saveProfile(_ profile: UserProfileModel) async throws
    func updateProfile(_ profile: UserProfileModel) async throws
    func deleteProfile() async throws
}

/// 사용자 프로필 스토리지 구현
@MainActor
public final class UserProfileStorage: UserProfileStorageProtocol {
    private let container: ModelContainer

    nonisolated public init(container: ModelContainer = StorageContainer.shared.container) {
        self.container = container
    }

    public func fetchProfile() async throws -> UserProfileModel? {
        let context = container.mainContext
        let descriptor = FetchDescriptor<UserProfileModel>()
        let profiles = try context.fetch(descriptor)
        return profiles.first
    }

    public func saveProfile(_ profile: UserProfileModel) async throws {
        let context = container.mainContext
        context.insert(profile)
        try context.save()
    }

    public func updateProfile(_ profile: UserProfileModel) async throws {
        let context = container.mainContext
        profile.updatedAt = Date()
        try context.save()
    }

    public func deleteProfile() async throws {
        let context = container.mainContext
        let descriptor = FetchDescriptor<UserProfileModel>()
        let profiles = try context.fetch(descriptor)
        for profile in profiles {
            context.delete(profile)
        }
        try context.save()
    }
}
