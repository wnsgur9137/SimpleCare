//
//  OnboardingCoordinator.swift
//  OnboardingPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import BasePresentation
import ProfileDomain

public protocol OnboardingCoordinatorDependency {
    var saveUserProfile: @Sendable (UserProfile) async throws -> Void { get }
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
        OnboardingContainerView(
            saveUserProfile: dependencies.saveUserProfile,
            onComplete: { [weak self] in
                self?.onComplete?()
            }
        )
    }
}

// MARK: - Container View

private struct OnboardingContainerView: View {
    let saveUserProfile: @Sendable (UserProfile) async throws -> Void
    let onComplete: () -> Void

    @State private var store: StoreOf<OnboardingFeature>

    init(
        saveUserProfile: @escaping @Sendable (UserProfile) async throws -> Void,
        onComplete: @escaping () -> Void
    ) {
        self.saveUserProfile = saveUserProfile
        self.onComplete = onComplete
        self._store = State(
            initialValue: Store(initialState: OnboardingFeature.State()) {
                OnboardingFeature()
            } withDependencies: {
                $0.saveUserProfile = saveUserProfile
            }
        )
    }

    var body: some View {
        OnboardingView(store: store)
            .onChange(of: store.isCompleted) { _, isCompleted in
                if isCompleted {
                    onComplete()
                }
            }
    }
}
