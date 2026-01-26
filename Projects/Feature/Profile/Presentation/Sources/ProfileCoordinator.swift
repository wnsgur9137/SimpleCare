//
//  ProfileCoordinator.swift
//  ProfilePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import BasePresentation

public protocol ProfileCoordinatorDependency {
    func makeProfileViewModel() -> ProfileViewModel
}

/// 프로필 Coordinator
public final class ProfileCoordinator: ObservableObject, Coordinator {
    
    private let dependencies: ProfileCoordinatorDependency

    public init(dependencies: ProfileCoordinatorDependency) {
        self.dependencies = dependencies
    }

    @ViewBuilder
    public func start() -> some View {
        makeProfileView()
    }

    @ViewBuilder
    private func makeProfileView() -> some View {
        ProfileView(viewModel: dependencies.makeProfileViewModel())
    }
}
