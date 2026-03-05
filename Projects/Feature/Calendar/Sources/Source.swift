//
//  CalendarDIContainer.swift
//  Calendar
//
//  Created by JunHyeok Lee on 2/21/26.
//

import Foundation
import BasePresentation
import HomeDomain
import HomeData
import CalendarPresentation
import HealthKitInfra

@_exported import CalendarData
@_exported import CalendarDomain
@_exported import CalendarPresentation

/// Calendar DI Container
public final class CalendarDIContainer: DIContainer, CalendarCoordinatorDependency {
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

        let homeRepository = HomeRepository(healthKitManager: HealthKitManager.shared)
        let summaryUseCase = GetDailySummaryUseCase(repository: homeRepository)

        self.homeClient = HomeClient(
            getDailySummary: { date, userProfileId, goalCalories, macroGoals in
                try await summaryUseCase.execute(date: date, userProfileId: userProfileId, goalCalories: goalCalories, macroGoals: macroGoals)
            },
            generateInsight: { _ in .defaultInsight },
            getWeeklyStatus: { _, _, _ in [] },
            getWeeklyReport: { _, _, _ in throw NSError(domain: "Not implemented", code: -1) },
            getMonthlyReport: { _, _, _ in throw NSError(domain: "Not implemented", code: -1) },
            requestHealthKitAuth: {},
            isHealthKitAvailable: { false },
            checkHealthKitAuthStatus: { false },
            openHealthSettings: {}
        )
    }

    // MARK: - CalendarCoordinatorDependency

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
