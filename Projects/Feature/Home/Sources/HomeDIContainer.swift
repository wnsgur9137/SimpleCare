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
        public let macroGoals: MacroGoals

        public init(userProfileId: UUID, goalCalories: Int, macroGoals: MacroGoals = .default) {
            self.userProfileId = userProfileId
            self.goalCalories = goalCalories
            self.macroGoals = macroGoals
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
            getDailySummary: { date, userProfileId, goalCalories, macroGoals in
                try await summaryUseCase.execute(date: date, userProfileId: userProfileId, goalCalories: goalCalories, macroGoals: macroGoals)
            },
            generateInsight: { summary in
                try await insightUseCase.execute(summary: summary)
            },
            getWeeklyStatus: { baseDate, userProfileId, goalCalories in
                try await homeRepository.getWeeklyStatus(baseDate: baseDate, userProfileId: userProfileId, goalCalories: goalCalories)
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

    public var macroGoals: MacroGoals {
        dependencies.macroGoals
    }
}
