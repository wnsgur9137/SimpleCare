//
//  FavoriteFoodDataRepository.swift
//  MealData
//
//  Created by SimpleCare on 2/18/26.
//

import Foundation
import MealDomain
import StorageInfra

/// 즐겨찾기 음식 Data Repository - StorageInfra 어댑터
public final class FavoriteFoodDataRepository: FavoriteFoodDomainRepositoryProtocol, Sendable {
    private let storage: FavoriteFoodRepository

    public init(storage: FavoriteFoodRepository = FavoriteFoodRepository()) {
        self.storage = storage
    }

    public func getFavorites(userProfileId: UUID) async throws -> [FavoriteFood] {
        let models = try await storage.fetchFavorites(userProfileId: userProfileId)
        return models.map { $0.toEntity() }
    }

    public func getMostUsed(limit: Int, userProfileId: UUID) async throws -> [FavoriteFood] {
        let models = try await storage.fetchMostUsed(limit: limit, userProfileId: userProfileId)
        return models.map { $0.toEntity() }
    }

    public func saveFavorite(_ food: FavoriteFood) async throws {
        let model = food.toModel()
        try await storage.saveFavorite(model)
    }

    public func deleteFavorite(_ food: FavoriteFood) async throws {
        let favorites = try await storage.fetchFavorites(userProfileId: food.userProfileId)
        guard let model = favorites.first(where: { $0.id == food.id }) else { return }
        try await storage.deleteFavorite(model)
    }

    public func incrementUsage(_ food: FavoriteFood) async throws {
        let favorites = try await storage.fetchFavorites(userProfileId: food.userProfileId)
        guard let model = favorites.first(where: { $0.id == food.id }) else { return }
        try await storage.incrementUsage(model)
    }
}

// MARK: - Mapping Extensions

extension FavoriteFoodModel {
    func toEntity() -> FavoriteFood {
        FavoriteFood(
            id: id,
            userProfileId: userProfileId,
            name: name,
            brand: brand,
            servingSize: servingSize,
            servingUnit: servingUnit,
            caloriesPerServing: caloriesPerServing,
            proteinPerServing: proteinPerServing,
            carbsPerServing: carbsPerServing,
            fatPerServing: fatPerServing,
            usageCount: usageCount,
            lastUsedAt: lastUsedAt
        )
    }
}

extension FavoriteFood {
    func toModel() -> FavoriteFoodModel {
        FavoriteFoodModel(
            id: id,
            userProfileId: userProfileId,
            name: name,
            brand: brand,
            servingSize: servingSize,
            servingUnit: servingUnit,
            caloriesPerServing: caloriesPerServing,
            proteinPerServing: proteinPerServing,
            carbsPerServing: carbsPerServing,
            fatPerServing: fatPerServing,
            usageCount: usageCount,
            lastUsedAt: lastUsedAt
        )
    }
}
