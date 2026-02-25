//
//  DeleteMealUseCase.swift
//  MealDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

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
