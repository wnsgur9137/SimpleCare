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
    public let homeClient: HomeClient

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies

        let homeRepository = HomeRepository()
        let insightService = HomeInsightService()
        let summaryUseCase = GetDailySummaryUseCase(repository: homeRepository)
        let insightUseCase = GenerateDailyInsightUseCase(insightService: insightService)

        self.homeClient = HomeClient(
            getDailySummary: { date, userProfileId, goalCalories in
                try await summaryUseCase.execute(date: date, userProfileId: userProfileId, goalCalories: goalCalories)
            },
            generateInsight: { summary in
                try await insightUseCase.execute(summary: summary)
            }
        )
    }

    // MARK: - HomeCoordinatorDependency

    public var userProfileId: UUID {
        dependencies.userProfileId
    }

    public var goalCalories: Int {
        dependencies.goalCalories
    }
}
