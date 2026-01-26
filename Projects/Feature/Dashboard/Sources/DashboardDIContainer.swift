//
//  DashboardDIContainer.swift
//  Dashboard
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import BasePresentation
import DashboardDomain
import DashboardData
import DashboardPresentation

/// Dashboard DI Container
public final class DashboardDIContainer: DIContainer, DashboardCoordinatorDependency {
    public struct Dependencies {
        public let userProfileId: UUID
        public let goalCalories: Int

        public init(userProfileId: UUID, goalCalories: Int) {
            self.userProfileId = userProfileId
            self.goalCalories = goalCalories
        }
    }

    public let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - DashboardCoordinatorDependency

    public var userProfileId: UUID {
        dependencies.userProfileId
    }

    public var goalCalories: Int {
        dependencies.goalCalories
    }

    // MARK: - Repository

    private func makeDashboardRepository() -> DashboardRepositoryProtocol {
        DashboardRepository()
    }

    // MARK: - Use Cases

    private func makeGetDailySummaryUseCase() -> GetDailySummaryUseCaseProtocol {
        GetDailySummaryUseCase(repository: makeDashboardRepository())
    }

    private func makeGenerateInsightUseCase() -> GenerateDailyInsightUseCaseProtocol {
        GenerateDailyInsightUseCase(repository: makeDashboardRepository())
    }

    // MARK: - TCA Dependencies

    public var getDailySummary: @Sendable (Date, UUID, Int) async throws -> DailySummary {
        let useCase = makeGetDailySummaryUseCase()
        return { date, userProfileId, goalCalories in
            try await useCase.execute(date: date, userProfileId: userProfileId, goalCalories: goalCalories)
        }
    }

    public var generateDailyInsight: @Sendable (DailySummary, [String]) async throws -> DailyInsight {
        let useCase = makeGenerateInsightUseCase()
        return { summary, mealNames in
            try await useCase.execute(summary: summary, mealNames: mealNames)
        }
    }
}
