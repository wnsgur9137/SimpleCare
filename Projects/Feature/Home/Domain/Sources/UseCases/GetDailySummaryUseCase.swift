//
//  GetDailySummaryUseCase.swift
//  HomeDomain
//
//  Created by SimpleCare on 2/15/26.
//

import Foundation

/// 홈 일일 요약 저장소 프로토콜 (Data layer에서 구현)
public protocol HomeDailySummaryRepositoryProtocol: Sendable {
    func getDailySummary(date: Date, userProfileId: UUID, goalCalories: Int) async throws -> HomeDailySummary
}

/// 일일 요약 조회 UseCase 프로토콜
public protocol GetDailySummaryUseCaseProtocol: Sendable {
    func execute(date: Date, userProfileId: UUID, goalCalories: Int) async throws -> HomeDailySummary
}

/// 일일 요약 조회 UseCase 구현
public struct GetDailySummaryUseCase: GetDailySummaryUseCaseProtocol {
    private let repository: HomeDailySummaryRepositoryProtocol

    public init(repository: HomeDailySummaryRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(date: Date, userProfileId: UUID, goalCalories: Int) async throws -> HomeDailySummary {
        try await repository.getDailySummary(date: date, userProfileId: userProfileId, goalCalories: goalCalories)
    }
}
