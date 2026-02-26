//
//  UpdateMealUseCase.swift
//  MealDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

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
