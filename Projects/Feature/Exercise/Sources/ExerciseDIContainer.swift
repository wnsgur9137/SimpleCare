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

    private lazy var customExerciseRepository: CustomExerciseDomainRepositoryProtocol = CustomExerciseDataRepository()

    // MARK: - Use Cases

    private func makeRecordExerciseUseCase() -> RecordExerciseUseCaseProtocol {
        RecordExerciseUseCase(repository: makeExerciseRepository())
    }

    private func makeGetDailyExercisesUseCase() -> GetDailyExercisesUseCaseProtocol {
        GetDailyExercisesUseCase(repository: makeExerciseRepository())
    }

    private func makeGetCustomExercisesUseCase() -> GetCustomExercisesUseCaseProtocol {
        GetCustomExercisesUseCase(repository: customExerciseRepository)
    }

    private func makeSaveCustomExerciseUseCase() -> SaveCustomExerciseUseCaseProtocol {
        SaveCustomExerciseUseCase(repository: customExerciseRepository)
    }

    private func makeDeleteCustomExerciseUseCase() -> DeleteCustomExerciseUseCaseProtocol {
        DeleteCustomExerciseUseCase(repository: customExerciseRepository)
    }

    private func makeUpdateExerciseUseCase() -> UpdateExerciseUseCaseProtocol {
        UpdateExerciseUseCase(repository: makeExerciseRepository())
    }

    private func makeDeleteExerciseUseCase() -> DeleteExerciseUseCaseProtocol {
        DeleteExerciseUseCase(repository: makeExerciseRepository())
    }

    private func makeFetchExerciseUseCase() -> FetchExerciseUseCaseProtocol {
        FetchExerciseUseCase(repository: makeExerciseRepository())
    }

    // MARK: - TCA Dependencies

    public var exerciseClient: ExerciseClient {
        let recordUseCase = makeRecordExerciseUseCase()
        let fetchDailyUseCase = makeGetDailyExercisesUseCase()
        let getCustomUseCase = makeGetCustomExercisesUseCase()
        let saveCustomUseCase = makeSaveCustomExerciseUseCase()
        let deleteCustomUseCase = makeDeleteCustomExerciseUseCase()
        let updateUseCase = makeUpdateExerciseUseCase()
        let deleteUseCase = makeDeleteExerciseUseCase()
        let fetchUseCase = makeFetchExerciseUseCase()

        return ExerciseClient(
            recordExercise: { record in
                try await recordUseCase.execute(exercise: record)
            },
            updateExercise: { record in
                try await updateUseCase.execute(exercise: record)
            },
            deleteExercise: { record in
                try await deleteUseCase.execute(exercise: record)
            },
            fetchExercise: { id in
                try await fetchUseCase.execute(id: id)
            },
            fetchExercises: { date, userProfileId in
                try await fetchDailyUseCase.execute(date: date, userProfileId: userProfileId)
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
