//
//  DailyInsightService.swift
//  AIServiceInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// 일일 인사이트 결과
public struct DailyInsightResult: Codable {
    public let comment: String
    public let emoji: String

    public init(comment: String, emoji: String) {
        self.comment = comment
        self.emoji = emoji
    }

    /// 기본 인사이트 (AI 실패 시 사용)
    public static var defaultInsight: DailyInsightResult {
        DailyInsightResult(
            comment: "오늘도 건강한 식단을 위해 노력해주세요!",
            emoji: "💪"
        )
    }
}

/// 일일 식단 요약 정보
public struct DailySummaryInput {
    public let totalCalories: Int
    public let totalProtein: Double
    public let totalCarbs: Double
    public let totalFat: Double
    public let goalCalories: Int
    public let mealNames: [String]

    public init(
        totalCalories: Int,
        totalProtein: Double,
        totalCarbs: Double,
        totalFat: Double,
        goalCalories: Int,
        mealNames: [String]
    ) {
        self.totalCalories = totalCalories
        self.totalProtein = totalProtein
        self.totalCarbs = totalCarbs
        self.totalFat = totalFat
        self.goalCalories = goalCalories
        self.mealNames = mealNames
    }
}

/// 일일 인사이트 서비스 프로토콜
public protocol DailyInsightServiceProtocol: Sendable {
    func generateInsight(from summary: DailySummaryInput) async throws -> DailyInsightResult
}

/// AI 기반 일일 인사이트 서비스
public actor DailyInsightService: DailyInsightServiceProtocol {
    private let client: GeminiClient

    public init(client: GeminiClient) {
        self.client = client
    }

    public init(configuration: GeminiConfiguration = GeminiConfiguration()) {
        self.client = GeminiClient(configuration: configuration)
    }

    /// 일일 식단 요약에서 인사이트 생성
    public func generateInsight(from summary: DailySummaryInput) async throws -> DailyInsightResult {
        let systemPrompt = """
        당신은 친근한 영양사 AI입니다.
        사용자의 하루 식단을 분석하고 격려와 조언이 담긴 한 줄 코멘트를 작성해주세요.
        응답은 반드시 JSON 형식으로만: {"comment": "코멘트 내용", "emoji": "적절한 이모지"}
        코멘트는 20자 내외로 간결하게 작성하세요.
        """

        let userPrompt = NutritionPrompts.dailySummaryPrompt(
            totalCalories: summary.totalCalories,
            totalProtein: summary.totalProtein,
            totalCarbs: summary.totalCarbs,
            totalFat: summary.totalFat,
            goalCalories: summary.goalCalories,
            meals: summary.mealNames
        )

        let response = try await client.generateContent(
            systemPrompt: systemPrompt,
            userMessage: userPrompt,
            model: .flashLite,
            temperature: 0.7,
            maxTokens: 200
        )

        guard let content = response.text else {
            return .defaultInsight
        }

        return parseInsightResponse(content)
    }

    // MARK: - Private

    private func parseInsightResponse(_ content: String) -> DailyInsightResult {
        let jsonContent = extractJSON(from: content)

        guard let data = jsonContent.data(using: .utf8),
              let result = try? JSONDecoder().decode(DailyInsightResult.self, from: data) else {
            return .defaultInsight
        }

        return result
    }

    private func extractJSON(from text: String) -> String {
        if let jsonStart = text.range(of: "{"),
           let jsonEnd = text.range(of: "}", options: .backwards) {
            return String(text[jsonStart.lowerBound...jsonEnd.upperBound])
        }
        return text
    }
}
