//
//  ExerciseRepository.swift
//  ExerciseData
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import ExerciseDomain
import StorageInfra

public final class ExerciseRepository: ExerciseRepositoryProtocol, @unchecked Sendable {
    private let storage: ExerciseRecordRepository

    public init(storage: ExerciseRecordRepository = ExerciseRecordRepository()) {
        self.storage = storage
    }

    public func getExercises(for date: Date, userProfileId: UUID) async throws -> [ExerciseRecord] {
        let models = try await storage.fetchExercises(for: date, userProfileId: userProfileId)
        return models.map { $0.toEntity() }
    }

    public func getExercises(from startDate: Date, to endDate: Date, userProfileId: UUID) async throws -> [ExerciseRecord] {
        let models = try await storage.fetchExercises(from: startDate, to: endDate, userProfileId: userProfileId)
        return models.map { $0.toEntity() }
    }

    public func saveExercise(_ exercise: ExerciseRecord) async throws {
        let model = exercise.toModel()
        try await storage.saveExercise(model)
    }

    public func updateExercise(_ exercise: ExerciseRecord) async throws {
        let models = try await storage.fetchExercises(for: exercise.date, userProfileId: exercise.userProfileId)
        guard let existingModel = models.first(where: { $0.id == exercise.id }) else {
            throw ExerciseRepositoryError.exerciseNotFound
        }
        exercise.updateModel(existingModel)
        try await storage.updateExercise(existingModel)
    }

    public func deleteExercise(_ exercise: ExerciseRecord) async throws {
        let models = try await storage.fetchExercises(for: exercise.date, userProfileId: exercise.userProfileId)
        guard let model = models.first(where: { $0.id == exercise.id }) else { return }
        try await storage.deleteExercise(model)
    }
}

public enum ExerciseRepositoryError: LocalizedError {
    case exerciseNotFound

    public var errorDescription: String? {
        switch self {
        case .exerciseNotFound: return "운동 기록을 찾을 수 없습니다"
        }
    }
}

// MARK: - Mapping

extension ExerciseRecordModel {
    func toEntity() -> ExerciseRecord {
        ExerciseRecord(
            id: id,
            userProfileId: userProfileId,
            exerciseType: exerciseType.toEntity(),
            intensity: intensity.toEntity(),
            durationMinutes: durationMinutes,
            caloriesBurned: caloriesBurned,
            userWeightKg: userWeightKg,
            date: date,
            notes: notes,
            customExerciseName: customExerciseName,
            customMET: customMET,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension ExerciseRecord {
    func toModel() -> ExerciseRecordModel {
        ExerciseRecordModel(
            id: id,
            userProfileId: userProfileId,
            exerciseType: exerciseType.toStorageModel(),
            intensity: intensity.toStorageModel(),
            durationMinutes: durationMinutes,
            caloriesBurned: caloriesBurned,
            userWeightKg: userWeightKg,
            date: date,
            notes: notes,
            customExerciseName: customExerciseName,
            customMET: customMET,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    func updateModel(_ model: ExerciseRecordModel) {
        model.exerciseType = exerciseType.toStorageModel()
        model.intensity = intensity.toStorageModel()
        model.durationMinutes = durationMinutes
        model.caloriesBurned = caloriesBurned
        model.notes = notes
        model.customExerciseName = customExerciseName
        model.customMET = customMET
        model.updatedAt = Date()
    }
}

// MARK: - Enum Mapping

extension StorageInfra.ExerciseType {
    func toEntity() -> ExerciseDomain.ExerciseType {
        ExerciseDomain.ExerciseType(rawValue: self.rawValue) ?? .other
    }
}

extension ExerciseDomain.ExerciseType {
    func toStorageModel() -> StorageInfra.ExerciseType {
        StorageInfra.ExerciseType(rawValue: self.rawValue) ?? .other
    }
}

extension StorageInfra.ExerciseIntensity {
    func toEntity() -> ExerciseDomain.ExerciseIntensity {
        switch self {
        case .light: return .light
        case .moderate: return .moderate
        case .vigorous: return .vigorous
        }
    }
}

extension ExerciseDomain.ExerciseIntensity {
    func toStorageModel() -> StorageInfra.ExerciseIntensity {
        switch self {
        case .light: return .light
        case .moderate: return .moderate
        case .vigorous: return .vigorous
        }
    }
}
