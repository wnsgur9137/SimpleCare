//
//  WeightCoordinator.swift
//  WeightPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import BasePresentation

public protocol WeightCoordinatorDependency {
    @MainActor func makeWeightViewModel() -> WeightViewModel
}

public final class WeightCoordinator: ObservableObject, @MainActor Coordinator {
    private let dependencies: WeightCoordinatorDependency

    public init(dependencies: WeightCoordinatorDependency) {
        self.dependencies = dependencies
    }

    @MainActor @ViewBuilder
    public func start() -> some View {
        WeightView(viewModel: dependencies.makeWeightViewModel())
    }
}
