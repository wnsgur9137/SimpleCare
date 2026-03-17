//
//  MealRepository.swift
//  MealData
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import MealDomain
import StorageInfra

/// Meal Repository 구현
public final class MealRepository: MealRepositoryProtocol, Sendable {
    private let storage: MealRecordRepository

    public init(storage: MealRecordRepository = MealRecordRepository()) {
        self.storage = storage
    }

    public func getMeals(for date: Date, userProfileId: UUID) async throws -> [MealRecord] {
        let models = try await storage.fetchMeals(for: date, userProfileId: userProfileId)
        return models.map { $0.toEntity() }
    }

    public func getMeals(from startDate: Date, to endDate: Date, userProfileId: UUID) async throws -> [MealRecord] {
        let models = try await storage.fetchMeals(from: startDate, to: endDate, userProfileId: userProfileId)
        return models.map { $0.toEntity() }
    }

    public func getMeal(by id: UUID) async throws -> MealRecord? {
        guard let model = try await storage.fetchMeal(by: id) else { return nil }
        return model.toEntity()
    }

    public func saveMeal(_ meal: MealRecord) async throws {
        let model = meal.toModel()
        try await storage.saveMeal(model)
    }

    public func updateMeal(_ meal: MealRecord) async throws {
        guard let existingModel = try await storage.fetchMeal(by: meal.id) else {
            throw MealRepositoryError.mealNotFound
        }
        meal.updateModel(existingModel)
        try await storage.updateMeal(existingModel)
    }

    public func deleteMeal(_ meal: MealRecord) async throws {
        try await storage.deleteMeal(by: meal.id)
    }
}

public enum MealRepositoryError: LocalizedError {
    case mealNotFound

    public var errorDescription: String? {
        switch self {
        case .mealNotFound: return "식사 기록을 찾을 수 없습니다"
        }
    }
}

// MARK: - Mapping Extensions

extension MealRecordModel {
    func toEntity() -> MealRecord {
        MealRecord(
            id: id,
            userProfileId: userProfileId,
            mealType: mealType.toEntity(),
            date: date,
            foodItems: foodItems.map { $0.toEntity() },
            notes: notes,
            imageDataPath: imageDataPath,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension MealRecord {
    func toModel() -> MealRecordModel {
        let model = MealRecordModel(
            id: id,
            userProfileId: userProfileId,
            mealType: mealType.toStorageModel(),
            date: date,
            notes: notes,
            imageDataPath: imageDataPath,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
        model.foodItems = foodItems.map { $0.toModel() }
        return model
    }

    func updateModel(_ model: MealRecordModel) {
        model.mealType = mealType.toStorageModel()
        model.date = date
        model.notes = notes
        model.imageDataPath = imageDataPath
        model.foodItems = foodItems.map { $0.toModel() }
        model.updatedAt = Date()
    }
}

extension FoodItemModel {
    func toEntity() -> FoodItem {
        FoodItem(
            id: id,
            name: name,
            brand: brand,
            servingSize: servingSize,
            servingUnit: servingUnit,
            quantity: quantity,
            caloriesPerServing: caloriesPerServing,
            proteinPerServing: proteinPerServing,
            carbsPerServing: carbsPerServing,
            fatPerServing: fatPerServing,
            fiberPerServing: fiberPerServing,
            sodiumPerServing: sodiumPerServing,
            sugarPerServing: sugarPerServing,
            nutritionSource: nutritionSource.toEntity(),
            aiConfidence: aiConfidence,
            createdAt: createdAt
        )
    }
}

extension FoodItem {
    func toModel() -> FoodItemModel {
        FoodItemModel(
            id: id,
            name: name,
            brand: brand,
            servingSize: servingSize,
            servingUnit: servingUnit,
            quantity: quantity,
            caloriesPerServing: caloriesPerServing,
            proteinPerServing: proteinPerServing,
            carbsPerServing: carbsPerServing,
            fatPerServing: fatPerServing,
            fiberPerServing: fiberPerServing,
            sodiumPerServing: sodiumPerServing,
            sugarPerServing: sugarPerServing,
            nutritionSource: nutritionSource.toStorageModel(),
            aiConfidence: aiConfidence
        )
    }
}

// MARK: - Enum Mapping

extension StorageInfra.MealType {
    func toEntity() -> MealDomain.MealType {
        switch self {
        case .breakfast: return .breakfast
        case .lunch: return .lunch
        case .dinner: return .dinner
        case .snack: return .snack
        }
    }
}

extension MealDomain.MealType {
    func toStorageModel() -> StorageInfra.MealType {
        switch self {
        case .breakfast: return .breakfast
        case .lunch: return .lunch
        case .dinner: return .dinner
        case .snack: return .snack
        }
    }
}

extension StorageInfra.NutritionSource {
    func toEntity() -> MealDomain.NutritionSource {
        switch self {
        case .aiEstimated: return .aiEstimated
        case .manual: return .manual
        case .database: return .database
        case .barcode: return .barcode
        }
    }
}

extension MealDomain.NutritionSource {
    func toStorageModel() -> StorageInfra.NutritionSource {
        switch self {
        case .aiEstimated: return .aiEstimated
        case .manual: return .manual
        case .database: return .database
        case .barcode: return .barcode
        }
    }
}
