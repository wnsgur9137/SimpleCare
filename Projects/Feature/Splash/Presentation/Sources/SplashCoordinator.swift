//
//  SplashCoordinator.swift
//  SplashPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
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
        SplashView(minimumDuration: dependencies.minimumDuration) { [weak self] in
            self?.onComplete?()
        }
    }
}
