//
//  FavoriteFoodRepository.swift
//  StorageInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import SwiftData

/// 즐겨찾기 음식 저장소 프로토콜
public protocol FavoriteFoodRepositoryProtocol: Sendable {
    func fetchFavorites(userProfileId: UUID) async throws -> [FavoriteFoodModel]
    func fetchMostUsed(limit: Int, userProfileId: UUID) async throws -> [FavoriteFoodModel]
    func searchFavorites(query: String, userProfileId: UUID) async throws -> [FavoriteFoodModel]
    func saveFavorite(_ favorite: FavoriteFoodModel) async throws
    func deleteFavorite(_ favorite: FavoriteFoodModel) async throws
    func incrementUsage(_ favorite: FavoriteFoodModel) async throws
}

/// 즐겨찾기 음식 저장소 구현
@MainActor
public final class FavoriteFoodRepository: FavoriteFoodRepositoryProtocol {
    private let container: ModelContainer

    nonisolated public init(container: ModelContainer = StorageContainer.shared.container) {
        self.container = container
    }

    public func fetchFavorites(userProfileId: UUID) async throws -> [FavoriteFoodModel] {
        let context = container.mainContext
        let predicate = #Predicate<FavoriteFoodModel> { favorite in
            favorite.userProfileId == userProfileId
        }
        var descriptor = FetchDescriptor<FavoriteFoodModel>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.name, order: .forward)]

        return try context.fetch(descriptor)
    }

    public func fetchMostUsed(limit: Int, userProfileId: UUID) async throws -> [FavoriteFoodModel] {
        let context = container.mainContext
        let predicate = #Predicate<FavoriteFoodModel> { favorite in
            favorite.userProfileId == userProfileId
        }
        var descriptor = FetchDescriptor<FavoriteFoodModel>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.usageCount, order: .reverse)]
        descriptor.fetchLimit = limit

        return try context.fetch(descriptor)
    }

    public func searchFavorites(query: String, userProfileId: UUID) async throws -> [FavoriteFoodModel] {
        let context = container.mainContext
        let lowercaseQuery = query.lowercased()
        let predicate = #Predicate<FavoriteFoodModel> { favorite in
            favorite.userProfileId == userProfileId &&
            favorite.name.localizedStandardContains(lowercaseQuery)
        }
        var descriptor = FetchDescriptor<FavoriteFoodModel>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.usageCount, order: .reverse)]

        return try context.fetch(descriptor)
    }

    public func saveFavorite(_ favorite: FavoriteFoodModel) async throws {
        let context = container.mainContext
        context.insert(favorite)
        try context.save()
    }

    public func deleteFavorite(_ favorite: FavoriteFoodModel) async throws {
        let context = container.mainContext
        context.delete(favorite)
        try context.save()
    }

    public func incrementUsage(_ favorite: FavoriteFoodModel) async throws {
        let context = container.mainContext
        favorite.recordUsage()
        try context.save()
    }
}
