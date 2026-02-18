//
//  FavoriteFoodUseCases.swift
//  MealDomain
//
//  Created by SimpleCare on 2/18/26.
//

import Foundation

/// 즐겨찾기 음식 저장소 프로토콜
public protocol FavoriteFoodDomainRepositoryProtocol: Sendable {
    func getFavorites(userProfileId: UUID) async throws -> [FavoriteFood]
    func getMostUsed(limit: Int, userProfileId: UUID) async throws -> [FavoriteFood]
    func saveFavorite(_ food: FavoriteFood) async throws
    func deleteFavorite(_ food: FavoriteFood) async throws
    func incrementUsage(_ food: FavoriteFood) async throws
}

/// 즐겨찾기 음식 조회 UseCase
public protocol GetFavoriteFoodsUseCaseProtocol: Sendable {
    func execute(userProfileId: UUID) async throws -> [FavoriteFood]
}

public struct GetFavoriteFoodsUseCase: GetFavoriteFoodsUseCaseProtocol {
    private let repository: FavoriteFoodDomainRepositoryProtocol

    public init(repository: FavoriteFoodDomainRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(userProfileId: UUID) async throws -> [FavoriteFood] {
        try await repository.getMostUsed(limit: 20, userProfileId: userProfileId)
    }
}

/// 즐겨찾기 음식 저장 UseCase
public protocol SaveFavoriteFoodUseCaseProtocol: Sendable {
    func execute(_ food: FavoriteFood) async throws
}

public struct SaveFavoriteFoodUseCase: SaveFavoriteFoodUseCaseProtocol {
    private let repository: FavoriteFoodDomainRepositoryProtocol

    public init(repository: FavoriteFoodDomainRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ food: FavoriteFood) async throws {
        try await repository.saveFavorite(food)
    }
}

/// 즐겨찾기 음식 삭제 UseCase
public protocol DeleteFavoriteFoodUseCaseProtocol: Sendable {
    func execute(_ food: FavoriteFood) async throws
}

public struct DeleteFavoriteFoodUseCase: DeleteFavoriteFoodUseCaseProtocol {
    private let repository: FavoriteFoodDomainRepositoryProtocol

    public init(repository: FavoriteFoodDomainRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ food: FavoriteFood) async throws {
        try await repository.deleteFavorite(food)
    }
}

/// 즐겨찾기 사용 기록 UseCase
public protocol IncrementFavoriteUsageUseCaseProtocol: Sendable {
    func execute(_ food: FavoriteFood) async throws
}

public struct IncrementFavoriteUsageUseCase: IncrementFavoriteUsageUseCaseProtocol {
    private let repository: FavoriteFoodDomainRepositoryProtocol

    public init(repository: FavoriteFoodDomainRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ food: FavoriteFood) async throws {
        try await repository.incrementUsage(food)
    }
}
