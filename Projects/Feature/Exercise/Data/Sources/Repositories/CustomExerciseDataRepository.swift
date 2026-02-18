//
//  CustomExerciseDataRepository.swift
//  ExerciseData
//
//  Created by SimpleCare on 2/18/26.
//

import Foundation
import ExerciseDomain
import StorageInfra

/// 커스텀 운동 Data Repository - StorageInfra 어댑터
public final class CustomExerciseDataRepository: CustomExerciseDomainRepositoryProtocol, @unchecked Sendable {
    private let storage: CustomExerciseStorageRepository

    public init(storage: CustomExerciseStorageRepository = CustomExerciseStorageRepository()) {
        self.storage = storage
    }

    public func getAll(userProfileId: UUID) async throws -> [CustomExercise] {
        let models = try await storage.fetchAll(userProfileId: userProfileId)
        return models.map { $0.toEntity() }
    }

    public func save(_ exercise: CustomExercise) async throws {
        let model = exercise.toModel()
        try await storage.save(model)
    }

    public func delete(_ exercise: CustomExercise) async throws {
        let all = try await storage.fetchAll(userProfileId: exercise.userProfileId)
        guard let model = all.first(where: { $0.id == exercise.id }) else { return }
        try await storage.delete(model)
    }
}

// MARK: - Mapping

extension CustomExerciseModel {
    func toEntity() -> CustomExercise {
        CustomExercise(
            id: id,
            userProfileId: userProfileId,
            name: name,
            category: category.toExerciseDomainCategory(),
            baseMET: baseMET,
            iconName: iconName
        )
    }
}

extension CustomExercise {
    func toModel() -> CustomExerciseModel {
        CustomExerciseModel(
            id: id,
            userProfileId: userProfileId,
            name: name,
            category: category.toStorageCategory(),
            baseMET: baseMET,
            iconName: iconName
        )
    }
}

extension StorageInfra.ExerciseCategory {
    func toExerciseDomainCategory() -> ExerciseDomain.ExerciseCategory {
        switch self {
        case .cardio: return .cardio
        case .strength: return .strength
        case .flexibility: return .flexibility
        case .sports: return .sports
        case .other: return .other
        }
    }
}

extension ExerciseDomain.ExerciseCategory {
    func toStorageCategory() -> StorageInfra.ExerciseCategory {
        switch self {
        case .cardio: return .cardio
        case .strength: return .strength
        case .flexibility: return .flexibility
        case .sports: return .sports
        case .other: return .other
        }
    }
}
