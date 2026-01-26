//
//  ExerciseUseCases.swift
//  ExerciseDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// 운동 기록 UseCase
public protocol RecordExerciseUseCaseProtocol: Sendable {
    func execute(exercise: ExerciseRecord) async throws
}

public struct RecordExerciseUseCase: RecordExerciseUseCaseProtocol {
    private let repository: ExerciseRepositoryProtocol

    public init(repository: ExerciseRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(exercise: ExerciseRecord) async throws {
        try await repository.saveExercise(exercise)
    }
}

/// 일일 운동 기록 조회 UseCase
public protocol GetDailyExercisesUseCaseProtocol: Sendable {
    func execute(date: Date, userProfileId: UUID) async throws -> [ExerciseRecord]
}

public struct GetDailyExercisesUseCase: GetDailyExercisesUseCaseProtocol {
    private let repository: ExerciseRepositoryProtocol

    public init(repository: ExerciseRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(date: Date, userProfileId: UUID) async throws -> [ExerciseRecord] {
        try await repository.getExercises(for: date, userProfileId: userProfileId)
    }
}

/// 칼로리 추정 UseCase
public protocol EstimateCalorieBurnUseCaseProtocol: Sendable {
    func execute(
        exerciseType: ExerciseType,
        intensity: ExerciseIntensity,
        durationMinutes: Int,
        weightKg: Double
    ) -> Int
}

public struct EstimateCalorieBurnUseCase: EstimateCalorieBurnUseCaseProtocol {
    public init() {}

    public func execute(
        exerciseType: ExerciseType,
        intensity: ExerciseIntensity,
        durationMinutes: Int,
        weightKg: Double
    ) -> Int {
        ExerciseRecord.calculateCalories(
            exerciseType: exerciseType,
            intensity: intensity,
            durationMinutes: durationMinutes,
            weightKg: weightKg
        )
    }
}

/// Exercise Repository 프로토콜
public protocol ExerciseRepositoryProtocol: Sendable {
    func getExercises(for date: Date, userProfileId: UUID) async throws -> [ExerciseRecord]
    func getExercises(from startDate: Date, to endDate: Date, userProfileId: UUID) async throws -> [ExerciseRecord]
    func saveExercise(_ exercise: ExerciseRecord) async throws
    func updateExercise(_ exercise: ExerciseRecord) async throws
    func deleteExercise(_ exercise: ExerciseRecord) async throws
}
