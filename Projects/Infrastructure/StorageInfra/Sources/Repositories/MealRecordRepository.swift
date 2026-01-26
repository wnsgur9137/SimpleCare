//
//  MealRecordRepository.swift
//  StorageInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import SwiftData

/// 식사 기록 저장소 프로토콜
public protocol MealRecordRepositoryProtocol: Sendable {
    func fetchMeals(for date: Date, userProfileId: UUID) async throws -> [MealRecordModel]
    func fetchMeals(from startDate: Date, to endDate: Date, userProfileId: UUID) async throws -> [MealRecordModel]
    func fetchMeal(by id: UUID) async throws -> MealRecordModel?
    func saveMeal(_ meal: MealRecordModel) async throws
    func updateMeal(_ meal: MealRecordModel) async throws
    func deleteMeal(_ meal: MealRecordModel) async throws
    func deleteMeal(by id: UUID) async throws
}

/// 식사 기록 저장소 구현
@MainActor
public final class MealRecordRepository: MealRecordRepositoryProtocol {
    private let container: ModelContainer

    nonisolated public init(container: ModelContainer = StorageContainer.shared.container) {
        self.container = container
    }

    public func fetchMeals(for date: Date, userProfileId: UUID) async throws -> [MealRecordModel] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let context = container.mainContext
        let predicate = #Predicate<MealRecordModel> { meal in
            meal.userProfileId == userProfileId &&
            meal.date >= startOfDay &&
            meal.date < endOfDay
        }
        var descriptor = FetchDescriptor<MealRecordModel>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.date, order: .forward)]

        return try context.fetch(descriptor)
    }

    public func fetchMeals(from startDate: Date, to endDate: Date, userProfileId: UUID) async throws -> [MealRecordModel] {
        let context = container.mainContext
        let predicate = #Predicate<MealRecordModel> { meal in
            meal.userProfileId == userProfileId &&
            meal.date >= startDate &&
            meal.date < endDate
        }
        var descriptor = FetchDescriptor<MealRecordModel>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.date, order: .forward)]

        return try context.fetch(descriptor)
    }

    public func fetchMeal(by id: UUID) async throws -> MealRecordModel? {
        let context = container.mainContext
        let predicate = #Predicate<MealRecordModel> { meal in
            meal.id == id
        }
        let descriptor = FetchDescriptor<MealRecordModel>(predicate: predicate)
        let meals = try context.fetch(descriptor)
        return meals.first
    }

    public func saveMeal(_ meal: MealRecordModel) async throws {
        let context = container.mainContext
        context.insert(meal)
        try context.save()
    }

    public func updateMeal(_ meal: MealRecordModel) async throws {
        let context = container.mainContext
        meal.updatedAt = Date()
        try context.save()
    }

    public func deleteMeal(_ meal: MealRecordModel) async throws {
        let context = container.mainContext
        context.delete(meal)
        try context.save()
    }

    public func deleteMeal(by id: UUID) async throws {
        guard let meal = try await fetchMeal(by: id) else { return }
        try await deleteMeal(meal)
    }
}
