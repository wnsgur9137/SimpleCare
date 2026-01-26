//
//  GetDailySummaryUseCase.swift
//  DashboardDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// 하루 요약 조회 UseCase
public protocol GetDailySummaryUseCaseProtocol: Sendable {
    func execute(date: Date, userProfileId: UUID, goalCalories: Int) async throws -> DailySummary
}

public struct GetDailySummaryUseCase: GetDailySummaryUseCaseProtocol {
    private let repository: DashboardRepositoryProtocol

    public init(repository: DashboardRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(date: Date, userProfileId: UUID, goalCalories: Int) async throws -> DailySummary {
        try await repository.getDailySummary(for: date, userProfileId: userProfileId, goalCalories: goalCalories)
    }
}

/// AI 인사이트 생성 UseCase
public protocol GenerateDailyInsightUseCaseProtocol: Sendable {
    func execute(summary: DailySummary, mealNames: [String]) async throws -> DailyInsight
}

public struct GenerateDailyInsightUseCase: GenerateDailyInsightUseCaseProtocol {
    private let repository: DashboardRepositoryProtocol

    public init(repository: DashboardRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(summary: DailySummary, mealNames: [String]) async throws -> DailyInsight {
        try await repository.generateDailyInsight(for: summary, mealNames: mealNames)
    }
}

/// Dashboard 저장소 프로토콜
public protocol DashboardRepositoryProtocol: Sendable {
    func getDailySummary(for date: Date, userProfileId: UUID, goalCalories: Int) async throws -> DailySummary
    func generateDailyInsight(for summary: DailySummary, mealNames: [String]) async throws -> DailyInsight
}
