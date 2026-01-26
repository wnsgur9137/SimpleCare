//
//  ExerciseCoordinator.swift
//  ExercisePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import BasePresentation

public protocol ExerciseCoordinatorDependency {
    @MainActor func makeExerciseRecordViewModel() -> ExerciseRecordViewModel
}

public final class ExerciseCoordinator: ObservableObject, Coordinator {
    private let dependencies: ExerciseCoordinatorDependency

    public init(dependencies: ExerciseCoordinatorDependency) {
        self.dependencies = dependencies
    }

    @MainActor @ViewBuilder
    public func start() -> some View {
        ExerciseRecordView(viewModel: dependencies.makeExerciseRecordViewModel())
    }
}
