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

    private lazy var exerciseRepository: ExerciseRepositoryProtocol = ExerciseRepository()

    private lazy var customExerciseRepository: CustomExerciseDomainRepositoryProtocol = CustomExerciseDataRepository()

    // MARK: - Use Cases

    private lazy var recordExerciseUseCase: RecordExerciseUseCaseProtocol = RecordExerciseUseCase(repository: exerciseRepository)

    private lazy var getDailyExercisesUseCase: GetDailyExercisesUseCaseProtocol = GetDailyExercisesUseCase(repository: exerciseRepository)

    private lazy var getCustomExercisesUseCase: GetCustomExercisesUseCaseProtocol = GetCustomExercisesUseCase(repository: customExerciseRepository)

    private lazy var saveCustomExerciseUseCase: SaveCustomExerciseUseCaseProtocol = SaveCustomExerciseUseCase(repository: customExerciseRepository)

    private lazy var deleteCustomExerciseUseCase: DeleteCustomExerciseUseCaseProtocol = DeleteCustomExerciseUseCase(repository: customExerciseRepository)

    private lazy var updateExerciseUseCase: UpdateExerciseUseCaseProtocol = UpdateExerciseUseCase(repository: exerciseRepository)

    private lazy var deleteExerciseUseCase: DeleteExerciseUseCaseProtocol = DeleteExerciseUseCase(repository: exerciseRepository)

    private lazy var fetchExerciseUseCase: FetchExerciseUseCaseProtocol = FetchExerciseUseCase(repository: exerciseRepository)

    private lazy var getExerciseHistoryUseCase: GetExerciseHistoryUseCaseProtocol = GetExerciseHistoryUseCase(repository: exerciseRepository)

    // MARK: - TCA Dependencies

    public lazy var exerciseClient: ExerciseClient = {
        let recordUseCase = self.recordExerciseUseCase
        let fetchDailyUseCase = self.getDailyExercisesUseCase
        let getCustomUseCase = self.getCustomExercisesUseCase
        let saveCustomUseCase = self.saveCustomExerciseUseCase
        let deleteCustomUseCase = self.deleteCustomExerciseUseCase
        let updateUseCase = self.updateExerciseUseCase
        let deleteUseCase = self.deleteExerciseUseCase
        let fetchUseCase = self.fetchExerciseUseCase
        let historyUseCase = self.getExerciseHistoryUseCase

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
            fetchExerciseHistory: { startDate, endDate, userProfileId in
                try await historyUseCase.execute(from: startDate, to: endDate, userProfileId: userProfileId)
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
    }()
}
