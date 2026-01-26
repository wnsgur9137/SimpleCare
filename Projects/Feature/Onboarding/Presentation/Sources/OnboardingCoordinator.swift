//
//  OnboardingCoordinator.swift
//  OnboardingPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import BasePresentation

public protocol OnboardingCoordinatorDependency {
    @MainActor func makeOnboardingViewModel() -> OnboardingViewModel
}

/// 온보딩 Coordinator
public final class OnboardingCoordinator: ObservableObject, Coordinator {
    private let dependencies: OnboardingCoordinatorDependency
    public var onComplete: (() -> Void)?

    public init(dependencies: OnboardingCoordinatorDependency, onComplete: (() -> Void)? = nil) {
        self.dependencies = dependencies
        self.onComplete = onComplete
    }

    @MainActor @ViewBuilder
    public func start() -> some View {
        makeOnboardingView()
    }

    @MainActor @ViewBuilder
    private func makeOnboardingView() -> some View {
        let viewModel = dependencies.makeOnboardingViewModel()
        viewModel.onComplete = { [weak self] in
            self?.onComplete?()
        }
        return OnboardingView(viewModel: viewModel)
    }
}
