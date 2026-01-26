//
//  DashboardCoordinator.swift
//  DashboardPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import BasePresentation

public protocol DashboardCoordinatorDependency {
    @MainActor func makeDashboardViewModel() -> DashboardViewModel
}

/// Dashboard Coordinator
public final class DashboardCoordinator: ObservableObject, Coordinator {
    private let dependencies: DashboardCoordinatorDependency

    public init(dependencies: DashboardCoordinatorDependency) {
        self.dependencies = dependencies
    }

    @MainActor @ViewBuilder
    public func start() -> some View {
        makeDashboardView()
    }

    @MainActor @ViewBuilder
    private func makeDashboardView() -> some View {
        DashboardView(viewModel: dependencies.makeDashboardViewModel())
    }
}
