//
//  ExerciseDIContainer.swift
//  Exercise
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import BasePresentation
import ExerciseDomain
import ExerciseData
import ExercisePresentation

public final class ExerciseDIContainer: DIContainer, @MainActor ExerciseCoordinatorDependency {
    public struct Dependencies {
        public let userProfileId: UUID
        public let userWeightKg: Double

        public init(userProfileId: UUID, userWeightKg: Double) {
            self.userProfileId = userProfileId
            self.userWeightKg = userWeightKg
        }
    }

    public let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    private func makeExerciseRepository() -> ExerciseRepositoryProtocol {
        ExerciseRepository()
    }

    private func makeRecordExerciseUseCase() -> RecordExerciseUseCaseProtocol {
        RecordExerciseUseCase(repository: makeExerciseRepository())
    }

    private func makeEstimateCaloriesUseCase() -> EstimateCalorieBurnUseCaseProtocol {
        EstimateCalorieBurnUseCase()
    }

    @MainActor
    public func makeExerciseRecordViewModel() -> ExerciseRecordViewModel {
        ExerciseRecordViewModel(
            recordExerciseUseCase: makeRecordExerciseUseCase(),
            estimateCaloriesUseCase: makeEstimateCaloriesUseCase(),
            userProfileId: dependencies.userProfileId,
            userWeightKg: dependencies.userWeightKg
        )
    }
}
