//
//  HomeInsightService.swift
//  HomeData
//
//  Created by SimpleCare on 2/15/26.
//

import Foundation
import HomeDomain
import AIServiceInfra

/// Home Insight Service 구현 - AIServiceInfra를 사용
public final class HomeInsightService: HomeInsightServiceProtocol, @unchecked Sendable {
    private let insightService: DailyInsightService

    public init(insightService: DailyInsightService? = nil) {
        self.insightService = insightService ?? DailyInsightService()
    }

    public func generateInsight(from summary: HomeDailySummary) async throws -> HomeInsight {
        let input = summary.toDailySummaryInput()
        let result = try await insightService.generateInsight(from: input)
        return result.toHomeInsight()
    }
}

// MARK: - Mapping Extensions

extension HomeDailySummary {
    func toDailySummaryInput() -> DailySummaryInput {
        let mealNames = meals.flatMap { $0.foodNames }
        return DailySummaryInput(
            totalCalories: totalCalories,
            totalProtein: totalProtein,
            totalCarbs: totalCarbs,
            totalFat: totalFat,
            goalCalories: goalCalories,
            mealNames: mealNames
        )
    }
}

extension DailyInsightResult {
    func toHomeInsight() -> HomeInsight {
        HomeInsight(
            comment: comment,
            emoji: emoji
        )
    }
}
