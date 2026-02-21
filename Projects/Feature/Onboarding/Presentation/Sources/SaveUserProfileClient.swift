//
//  SaveUserProfileClient.swift
//  OnboardingPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import ComposableArchitecture
import ProfileDomain

// MARK: - SaveUserProfileClient

public struct SaveUserProfileClient {
    public var save: @Sendable (UserProfile) async throws -> Void

    public init(save: @escaping @Sendable (UserProfile) async throws -> Void) {
        self.save = save
    }
}

extension SaveUserProfileClient: DependencyKey {
    public static var liveValue: SaveUserProfileClient {
        SaveUserProfileClient { _ in
            // Will be overridden by DI container
        }
    }

    public static var testValue: SaveUserProfileClient {
        SaveUserProfileClient { _ in }
    }
}

extension DependencyValues {
    public var saveUserProfile: @Sendable (UserProfile) async throws -> Void {
        get { self[SaveUserProfileClient.self].save }
        set { self[SaveUserProfileClient.self] = SaveUserProfileClient(save: newValue) }
    }
}
