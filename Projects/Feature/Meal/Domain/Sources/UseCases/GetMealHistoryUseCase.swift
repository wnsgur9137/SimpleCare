//
//  GetMealHistoryUseCase.swift
//  MealDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// 하루 식사 기록 조회 UseCase
public protocol GetDailyMealsUseCaseProtocol: Sendable {
    func execute(date: Date, userProfileId: UUID) async throws -> [MealRecord]
}

public struct GetDailyMealsUseCase: GetDailyMealsUseCaseProtocol {
    private let repository: MealRepositoryProtocol

    public init(repository: MealRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(date: Date, userProfileId: UUID) async throws -> [MealRecord] {
        try await repository.getMeals(for: date, userProfileId: userProfileId)
    }
}

/// 기간별 식사 기록 조회 UseCase
public protocol GetMealHistoryUseCaseProtocol: Sendable {
    func execute(from startDate: Date, to endDate: Date, userProfileId: UUID) async throws -> [MealRecord]
}

public struct GetMealHistoryUseCase: GetMealHistoryUseCaseProtocol {
    private let repository: MealRepositoryProtocol

    public init(repository: MealRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(from startDate: Date, to endDate: Date, userProfileId: UUID) async throws -> [MealRecord] {
        try await repository.getMeals(from: startDate, to: endDate, userProfileId: userProfileId)
    }
}
