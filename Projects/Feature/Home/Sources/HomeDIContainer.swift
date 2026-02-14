//
//  HomeDIContainer.swift
//  Home
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import BasePresentation
import HomeDomain
import HomeData
import HomePresentation

/// Home DI Container
public final class HomeDIContainer: DIContainer, HomeCoordinatorDependency {
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

    // MARK: - HomeCoordinatorDependency

    public var userProfileId: UUID {
        dependencies.userProfileId
    }

    public var goalCalories: Int {
        dependencies.goalCalories
    }

    // MARK: - Repository

    private func makeHomeRepository() -> HomeDailySummaryRepositoryProtocol {
        HomeRepository()
    }

    private func makeInsightService() -> HomeInsightServiceProtocol {
        HomeInsightService()
    }

    // MARK: - Use Cases

    private func makeGetDailySummaryUseCase() -> GetDailySummaryUseCaseProtocol {
        GetDailySummaryUseCase(repository: makeHomeRepository())
    }

    private func makeGenerateInsightUseCase() -> GenerateDailyInsightUseCaseProtocol {
        GenerateDailyInsightUseCase(insightService: makeInsightService())
    }

    // MARK: - HomeClient

    public var homeClient: HomeClient {
        let summaryUseCase = makeGetDailySummaryUseCase()
        let insightUseCase = makeGenerateInsightUseCase()

        return HomeClient(
            getDailySummary: { date, userProfileId, goalCalories in
                try await summaryUseCase.execute(date: date, userProfileId: userProfileId, goalCalories: goalCalories)
            },
            generateInsight: { summary in
                try await insightUseCase.execute(summary: summary)
            }
        )
    }
}
