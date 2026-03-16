//
//  NutritionEstimationService.swift
//  AIServiceInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// AI 영양 추정 결과
public struct NutritionEstimationResult: Codable {
    public let foods: [EstimatedFood]
    public let totalCalories: Int
    public let mealDescription: String?
    public let healthTip: String?
    public let portionNotes: String?
    public let error: String?

    public init(
        foods: [EstimatedFood],
        totalCalories: Int,
        mealDescription: String? = nil,
        healthTip: String? = nil,
        portionNotes: String? = nil,
        error: String? = nil
    ) {
        self.foods = foods
        self.totalCalories = totalCalories
        self.mealDescription = mealDescription
        self.healthTip = healthTip
        self.portionNotes = portionNotes
        self.error = error
    }
}

/// 추정된 음식 정보
public struct EstimatedFood: Codable {
    public let name: String
    public let servingSize: Double
    public let servingUnit: String
    public let calories: Int
    public let protein: Double
    public let carbs: Double
    public let fat: Double
    public let fiber: Double?
    public let sodium: Double?
    public let sugar: Double?
    public let confidence: Double
    public let estimatedPortion: String?

    public init(
        name: String,
        servingSize: Double,
        servingUnit: String,
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        fiber: Double? = nil,
        sodium: Double? = nil,
        sugar: Double? = nil,
        confidence: Double,
        estimatedPortion: String? = nil
    ) {
        self.name = name
        self.servingSize = servingSize
        self.servingUnit = servingUnit
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sodium = sodium
        self.sugar = sugar
        self.confidence = confidence
        self.estimatedPortion = estimatedPortion
    }
}

/// 영양 추정 서비스 프로토콜
public protocol NutritionEstimationServiceProtocol: Sendable {
    func estimateNutrition(from text: String) async throws -> NutritionEstimationResult
    func analyzeImage(_ imageData: Data) async throws -> NutritionEstimationResult
}

/// AI 기반 영양 추정 서비스
public actor NutritionEstimationService: NutritionEstimationServiceProtocol {
    private let client: GeminiClient

    public init(client: GeminiClient) {
        self.client = client
    }

    public init(configuration: GeminiConfiguration = GeminiConfiguration()) {
        self.client = GeminiClient(configuration: configuration)
    }

    /// 텍스트 설명으로 영양 정보 추정
    public func estimateNutrition(from text: String) async throws -> NutritionEstimationResult {
        let response = try await client.generateContent(
            systemPrompt: NutritionPrompts.textNutritionSystemPrompt,
            userMessage: NutritionPrompts.textNutritionUserPrompt(foodDescription: text),
            model: .flash,
            temperature: 0.3,
            maxTokens: 1500
        )

        guard let content = response.text else {
            throw NutritionEstimationError.noResponse
        }

        return try parseNutritionResponse(content)
    }

    /// 이미지로 음식 분석 및 영양 정보 추정
    public func analyzeImage(_ imageData: Data) async throws -> NutritionEstimationResult {
        let response = try await client.generateContentWithVision(
            systemPrompt: NutritionPrompts.imageAnalysisSystemPrompt,
            userMessage: NutritionPrompts.imageAnalysisUserPrompt,
            imageData: imageData,
            model: .flash,
            temperature: 0.3,
            maxTokens: 2000
        )

        guard let content = response.text else {
            throw NutritionEstimationError.noResponse
        }

        return try parseNutritionResponse(content)
    }

    // MARK: - Private

    private func parseNutritionResponse(_ content: String) throws -> NutritionEstimationResult {
        // JSON 부분만 추출
        let jsonContent = extractJSON(from: content)

        guard let data = jsonContent.data(using: .utf8) else {
            throw NutritionEstimationError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(NutritionEstimationResult.self, from: data)
        } catch {
            // 오류 응답 확인
            if let errorResponse = try? JSONDecoder().decode(ErrorOnlyResponse.self, from: data) {
                return NutritionEstimationResult(
                    foods: [],
                    totalCalories: 0,
                    error: errorResponse.error
                )
            }
            throw NutritionEstimationError.parsingFailed(error.localizedDescription)
        }
    }

    private func extractJSON(from text: String) -> String {
        // JSON 블록 찾기
        if let jsonStart = text.range(of: "{"),
           let jsonEnd = text.range(of: "}", options: .backwards) {
            return String(text[jsonStart.lowerBound...jsonEnd.upperBound])
        }
        return text
    }
}

// MARK: - Helper Types

private struct ErrorOnlyResponse: Decodable {
    let error: String
}

/// 영양 추정 에러
public enum NutritionEstimationError: LocalizedError {
    case noResponse
    case invalidResponse
    case parsingFailed(String)
    case imageProcessingFailed

    public var errorDescription: String? {
        switch self {
        case .noResponse:
            return "AI 응답을 받지 못했습니다"
        case .invalidResponse:
            return "잘못된 응답 형식입니다"
        case .parsingFailed(let detail):
            return "응답 파싱 실패: \(detail)"
        case .imageProcessingFailed:
            return "이미지 처리에 실패했습니다"
        }
    }
}
