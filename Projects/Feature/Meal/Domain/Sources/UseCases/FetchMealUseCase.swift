//
//  FetchMealUseCase.swift
//  MealDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

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
