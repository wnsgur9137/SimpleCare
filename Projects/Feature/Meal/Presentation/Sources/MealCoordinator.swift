//
//  MealCoordinator.swift
//  MealPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import BasePresentation

public protocol MealCoordinatorDependency {
    @MainActor func makeMealRecordViewModel() -> MealRecordViewModel
}

/// Meal Coordinator
public final class MealCoordinator: ObservableObject, Coordinator {
    private let dependencies: MealCoordinatorDependency

    public init(dependencies: MealCoordinatorDependency) {
        self.dependencies = dependencies
    }

    @MainActor @ViewBuilder
    public func start() -> some View {
        makeMealRecordView()
    }

    @MainActor @ViewBuilder
    private func makeMealRecordView() -> some View {
        MealRecordView(viewModel: dependencies.makeMealRecordViewModel())
    }
}
