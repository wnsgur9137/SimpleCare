//
//  CustomExerciseRepository.swift
//  StorageInfra
//
//  Created by SimpleCare on 2/18/26.
//

import Foundation
import SwiftData

/// 커스텀 운동 저장소 프로토콜
public protocol CustomExerciseStorageProtocol: Sendable {
    func fetchAll(userProfileId: UUID) async throws -> [CustomExerciseModel]
    func save(_ exercise: CustomExerciseModel) async throws
    func delete(_ exercise: CustomExerciseModel) async throws
}

/// 커스텀 운동 저장소 구현
@MainActor
public final class CustomExerciseStorageRepository: CustomExerciseStorageProtocol {
    private let container: ModelContainer

    nonisolated public init(container: ModelContainer = StorageContainer.shared.container) {
        self.container = container
    }

    public func fetchAll(userProfileId: UUID) async throws -> [CustomExerciseModel] {
        let context = container.mainContext
        let predicate = #Predicate<CustomExerciseModel> { exercise in
            exercise.userProfileId == userProfileId
        }
        var descriptor = FetchDescriptor<CustomExerciseModel>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.name, order: .forward)]
        return try context.fetch(descriptor)
    }

    public func save(_ exercise: CustomExerciseModel) async throws {
        let context = container.mainContext
        context.insert(exercise)
        try context.save()
    }

    public func delete(_ exercise: CustomExerciseModel) async throws {
        let context = container.mainContext
        context.delete(exercise)
        try context.save()
    }
}
