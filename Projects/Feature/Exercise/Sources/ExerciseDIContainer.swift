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

public final class ExerciseDIContainer: DIContainer, ExerciseCoordinatorDependency {
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

    // MARK: - ExerciseCoordinatorDependency

    public var userProfileId: UUID {
        dependencies.userProfileId
    }

    public var userWeightKg: Double {
        dependencies.userWeightKg
    }

    // MARK: - Repository

    private func makeExerciseRepository() -> ExerciseRepositoryProtocol {
        ExerciseRepository()
    }

    private func makeCustomExerciseRepository() -> CustomExerciseDomainRepositoryProtocol {
        CustomExerciseDataRepository()
    }

    // MARK: - Use Cases

    private func makeRecordExerciseUseCase() -> RecordExerciseUseCaseProtocol {
        RecordExerciseUseCase(repository: makeExerciseRepository())
    }

    private func makeGetDailyExercisesUseCase() -> GetDailyExercisesUseCaseProtocol {
        GetDailyExercisesUseCase(repository: makeExerciseRepository())
    }

    private func makeGetCustomExercisesUseCase() -> GetCustomExercisesUseCaseProtocol {
        GetCustomExercisesUseCase(repository: makeCustomExerciseRepository())
    }

    private func makeSaveCustomExerciseUseCase() -> SaveCustomExerciseUseCaseProtocol {
        SaveCustomExerciseUseCase(repository: makeCustomExerciseRepository())
    }

    private func makeDeleteCustomExerciseUseCase() -> DeleteCustomExerciseUseCaseProtocol {
        DeleteCustomExerciseUseCase(repository: makeCustomExerciseRepository())
    }

    // MARK: - TCA Dependencies

    public var exerciseClient: ExerciseClient {
        let recordUseCase = makeRecordExerciseUseCase()
        let fetchUseCase = makeGetDailyExercisesUseCase()
        let getCustomUseCase = makeGetCustomExercisesUseCase()
        let saveCustomUseCase = makeSaveCustomExerciseUseCase()
        let deleteCustomUseCase = makeDeleteCustomExerciseUseCase()

        return ExerciseClient(
            recordExercise: { record in
                try await recordUseCase.execute(exercise: record)
            },
            fetchExercises: { date, userProfileId in
                try await fetchUseCase.execute(date: date, userProfileId: userProfileId)
            },
            getCustomExercises: { userProfileId in
                try await getCustomUseCase.execute(userProfileId: userProfileId)
            },
            saveCustomExercise: { exercise in
                try await saveCustomUseCase.execute(exercise)
            },
            deleteCustomExercise: { exercise in
                try await deleteCustomUseCase.execute(exercise)
            }
        )
    }
}
