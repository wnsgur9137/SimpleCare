//
//  ExerciseRecordRepository.swift
//  StorageInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import SwiftData

/// 운동 기록 저장소 프로토콜
public protocol ExerciseRecordRepositoryProtocol: Sendable {
    func fetchExercises(for date: Date, userProfileId: UUID) async throws -> [ExerciseRecordModel]
    func fetchExercises(from startDate: Date, to endDate: Date, userProfileId: UUID) async throws -> [ExerciseRecordModel]
    func saveExercise(_ exercise: ExerciseRecordModel) async throws
    func updateExercise(_ exercise: ExerciseRecordModel) async throws
    func deleteExercise(_ exercise: ExerciseRecordModel) async throws
}

/// 운동 기록 저장소 구현
@MainActor
public final class ExerciseRecordRepository: ExerciseRecordRepositoryProtocol {
    private let container: ModelContainer

    nonisolated public init(container: ModelContainer = StorageContainer.shared.container) {
        self.container = container
    }

    public func fetchExercises(for date: Date, userProfileId: UUID) async throws -> [ExerciseRecordModel] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let context = container.mainContext
        let predicate = #Predicate<ExerciseRecordModel> { exercise in
            exercise.userProfileId == userProfileId &&
            exercise.date >= startOfDay &&
            exercise.date < endOfDay
        }
        var descriptor = FetchDescriptor<ExerciseRecordModel>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.date, order: .forward)]

        return try context.fetch(descriptor)
    }

    public func fetchExercises(from startDate: Date, to endDate: Date, userProfileId: UUID) async throws -> [ExerciseRecordModel] {
        let context = container.mainContext
        let predicate = #Predicate<ExerciseRecordModel> { exercise in
            exercise.userProfileId == userProfileId &&
            exercise.date >= startDate &&
            exercise.date < endDate
        }
        var descriptor = FetchDescriptor<ExerciseRecordModel>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.date, order: .forward)]

        return try context.fetch(descriptor)
    }

    public func saveExercise(_ exercise: ExerciseRecordModel) async throws {
        let context = container.mainContext
        context.insert(exercise)
        try context.save()
    }

    public func updateExercise(_ exercise: ExerciseRecordModel) async throws {
        let context = container.mainContext
        exercise.updatedAt = Date()
        try context.save()
    }

    public func deleteExercise(_ exercise: ExerciseRecordModel) async throws {
        let context = container.mainContext
        context.delete(exercise)
        try context.save()
    }
}
