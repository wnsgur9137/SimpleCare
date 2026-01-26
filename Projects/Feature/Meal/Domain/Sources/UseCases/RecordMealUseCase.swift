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
