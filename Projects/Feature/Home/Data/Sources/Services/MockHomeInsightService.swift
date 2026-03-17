//
//  MockHomeInsightService.swift
//  HomeData
//
//  Created by SimpleCare on 2/18/26.
//

import Foundation
import HomeDomain

/// Mock Home Insight Service - API 호출 없이 컨텍스트 기반 인사이트 반환
public final class MockHomeInsightService: HomeInsightServiceProtocol, Sendable {

    public init() {}

    public func generateInsight(from summary: HomeDailySummary) async throws -> HomeInsight {
        // Simulate network delay
        try await Task.sleep(for: .milliseconds(500))
        return generateContextualInsight(from: summary)
    }

    // MARK: - Private

    private func generateContextualInsight(from summary: HomeDailySummary) -> HomeInsight {
        let calorieRatio = summary.goalCalories > 0
            ? Double(summary.totalCalories) / Double(summary.goalCalories)
            : 0

        // No data recorded yet
        if summary.totalCalories == 0 && summary.meals.isEmpty {
            return Self.noDataInsights.randomElement()
                ?? HomeInsight(comment: "오늘 식사를 기록해보세요!", emoji: "📝")
        }

        // Over calories
        if calorieRatio > 1.1 {
            return Self.overCalorieInsights.randomElement()
                ?? HomeInsight(comment: "칼로리를 조금 초과했어요.", emoji: "⚠️")
        }

        // Low protein
        let proteinRatio = summary.proteinGoal > 0
            ? summary.totalProtein / Double(summary.proteinGoal)
            : 1.0
        if proteinRatio < 0.5 && summary.totalCalories > 0 {
            return Self.lowProteinInsights.randomElement()
                ?? HomeInsight(comment: "단백질을 더 섭취해보세요.", emoji: "🥚")
        }

        // Good balance
        if calorieRatio >= 0.8 && calorieRatio <= 1.1 {
            return Self.goodBalanceInsights.randomElement()
                ?? HomeInsight(comment: "잘 하고 있어요!", emoji: "👍")
        }

        // Under calories
        if calorieRatio < 0.6 {
            return Self.underCalorieInsights.randomElement()
                ?? HomeInsight(comment: "좀 더 드셔도 괜찮아요.", emoji: "🍽️")
        }

        // Default
        return Self.defaultInsights.randomElement()
            ?? HomeInsight(comment: "꾸준히 기록하는 습관이 중요해요!", emoji: "💪")
    }

    // MARK: - Insight Templates

    private static let noDataInsights: [HomeInsight] = [
        HomeInsight(comment: "오늘의 첫 식사를 기록해보세요! 기록이 건강의 시작이에요.", emoji: "📝"),
        HomeInsight(comment: "아직 오늘 기록이 없어요. 아침 식사는 하셨나요?", emoji: "🌅"),
        HomeInsight(comment: "식사 기록을 시작하면 건강 패턴을 파악할 수 있어요!", emoji: "📊"),
    ]

    private static let overCalorieInsights: [HomeInsight] = [
        HomeInsight(comment: "오늘 칼로리가 목표를 초과했어요. 저녁은 가볍게 드시는 건 어떨까요?", emoji: "🥗"),
        HomeInsight(comment: "칼로리를 조금 초과했지만 괜찮아요! 내일 가벼운 운동으로 밸런스를 맞춰보세요.", emoji: "🏃"),
        HomeInsight(comment: "오늘은 조금 많이 드셨네요. 산책 30분이면 100kcal를 소모할 수 있어요!", emoji: "🚶"),
    ]

    private static let lowProteinInsights: [HomeInsight] = [
        HomeInsight(comment: "단백질 섭취가 부족해 보여요. 계란이나 두부를 추가해보세요!", emoji: "🥚"),
        HomeInsight(comment: "근육 유지를 위해 단백질을 더 섭취해보세요. 닭가슴살이나 그릭요거트가 좋아요.", emoji: "💪"),
        HomeInsight(comment: "단백질이 좀 부족하네요. 간식으로 견과류는 어떨까요?", emoji: "🥜"),
    ]

    private static let goodBalanceInsights: [HomeInsight] = [
        HomeInsight(comment: "오늘 식단이 정말 좋아요! 이 페이스를 유지해보세요.", emoji: "🌟"),
        HomeInsight(comment: "균형 잡힌 식사를 하고 계시네요! 훌륭합니다.", emoji: "👏"),
        HomeInsight(comment: "목표 칼로리에 잘 맞추고 있어요. 꾸준함이 최고의 비결이에요!", emoji: "🎯"),
        HomeInsight(comment: "영양소 밸런스가 좋아요! 이대로 유지하면 건강해질 거예요.", emoji: "✨"),
    ]

    private static let underCalorieInsights: [HomeInsight] = [
        HomeInsight(comment: "아직 칼로리가 많이 부족해요. 영양가 있는 식사를 더 해주세요!", emoji: "🍽️"),
        HomeInsight(comment: "칼로리가 부족하면 기초대사량이 떨어질 수 있어요. 균형잡힌 식사를 해보세요.", emoji: "⚡"),
    ]

    private static let defaultInsights: [HomeInsight] = [
        HomeInsight(comment: "꾸준히 기록하는 습관이 건강의 비결이에요!", emoji: "💪"),
        HomeInsight(comment: "오늘도 건강한 선택을 위해 노력해주세요.", emoji: "🌿"),
        HomeInsight(comment: "작은 변화가 큰 차이를 만들어요. 화이팅!", emoji: "🔥"),
    ]
}
