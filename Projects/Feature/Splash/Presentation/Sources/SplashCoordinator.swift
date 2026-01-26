//
//  SplashCoordinator.swift
//  SplashPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import BasePresentation

public protocol SplashCoordinatorDependency {
    var minimumDuration: TimeInterval { get }
}

public final class SplashCoordinator: ObservableObject, @MainActor Coordinator {
    private let dependencies: SplashCoordinatorDependency
    public var onComplete: (() -> Void)?

    public init(dependencies: SplashCoordinatorDependency, onComplete: (() -> Void)? = nil) {
        self.dependencies = dependencies
        self.onComplete = onComplete
    }

    @MainActor @ViewBuilder
    public func start() -> some View {
        SplashContainerView(
            minimumDuration: dependencies.minimumDuration,
            onComplete: { [weak self] in
                self?.onComplete?()
            }
        )
    }
}

// MARK: - Container View for handling completion

private struct SplashContainerView: View {
    let minimumDuration: TimeInterval
    let onComplete: () -> Void

    @State private var store: StoreOf<SplashFeature>

    init(minimumDuration: TimeInterval, onComplete: @escaping () -> Void) {
        self.minimumDuration = minimumDuration
        self.onComplete = onComplete
        self._store = State(
            initialValue: Store(
                initialState: SplashFeature.State(minimumDuration: minimumDuration)
            ) {
                SplashFeature()
            }
        )
    }

    var body: some View {
        SplashView(store: store)
            .onChange(of: store.isCompleted) { _, isCompleted in
                if isCompleted {
                    onComplete()
                }
            }
    }
}
