//
//  RecordMealUseCase.swift
//  MealDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// 식사 기록 UseCase
public protocol RecordMealUseCaseProtocol: Sendable {
    func execute(meal: MealRecord) async throws
}

public struct RecordMealUseCase: RecordMealUseCaseProtocol {
    private let repository: MealRepositoryProtocol

    public init(repository: MealRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meal: MealRecord) async throws {
        try await repository.saveMeal(meal)
    }
}

/// 식사 기록 저장소 프로토콜
public protocol MealRepositoryProtocol: Sendable {
    func getMeals(for date: Date, userProfileId: UUID) async throws -> [MealRecord]
    func getMeals(from startDate: Date, to endDate: Date, userProfileId: UUID) async throws -> [MealRecord]
    func getMeal(by id: UUID) async throws -> MealRecord?
    func saveMeal(_ meal: MealRecord) async throws
    func updateMeal(_ meal: MealRecord) async throws
    func deleteMeal(_ meal: MealRecord) async throws
}

// MARK: - Update Meal UseCase

/// 식사 수정 UseCase
public protocol UpdateMealUseCaseProtocol: Sendable {
    func execute(meal: MealRecord) async throws
}

public struct UpdateMealUseCase: UpdateMealUseCaseProtocol {
    private let repository: MealRepositoryProtocol

    public init(repository: MealRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meal: MealRecord) async throws {
        try await repository.updateMeal(meal)
    }
}

// MARK: - Delete Meal UseCase

/// 식사 삭제 UseCase
public protocol DeleteMealUseCaseProtocol: Sendable {
    func execute(meal: MealRecord) async throws
}

public struct DeleteMealUseCase: DeleteMealUseCaseProtocol {
    private let repository: MealRepositoryProtocol

    public init(repository: MealRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meal: MealRecord) async throws {
        try await repository.deleteMeal(meal)
    }
}

// MARK: - Fetch Meal UseCase

/// 단일 식사 조회 UseCase
public protocol FetchMealUseCaseProtocol: Sendable {
    func execute(id: UUID) async throws -> MealRecord?
}

public struct FetchMealUseCase: FetchMealUseCaseProtocol {
    private let repository: MealRepositoryProtocol

    public init(repository: MealRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(id: UUID) async throws -> MealRecord? {
        try await repository.getMeal(by: id)
    }
}
