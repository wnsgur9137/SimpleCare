//
//  ProfileCoordinator.swift
//  ProfilePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import BasePresentation
import ProfileDomain

public protocol ProfileCoordinatorDependency {
    var profileClient: ProfileClient { get }
}

/// 프로필 Coordinator
public final class ProfileCoordinator: ObservableObject, Coordinator {
    private let dependencies: ProfileCoordinatorDependency

    public init(dependencies: ProfileCoordinatorDependency) {
        self.dependencies = dependencies
    }

    @ViewBuilder
    public func start() -> some View {
        ProfileContainerView(profileClient: dependencies.profileClient)
    }
}

// MARK: - Container View

private struct ProfileContainerView: View {
    let profileClient: ProfileClient

    @State private var store: StoreOf<ProfileFeature>

    init(profileClient: ProfileClient) {
        self.profileClient = profileClient
        self._store = State(
            initialValue: Store(initialState: ProfileFeature.State()) {
                ProfileFeature()
            } withDependencies: {
                $0.profileClient = profileClient
            }
        )
    }

    var body: some View {
        ProfileView(store: store)
    }
}
