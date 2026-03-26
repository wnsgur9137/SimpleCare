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

    /// 입력 텍스트 최대 길이 (500자)
    private static let maxInputLength = 500

    // MARK: - Cache

    private struct CacheEntry {
        let result: NutritionEstimationResult
        let timestamp: Date
    }

    private var cache: [String: CacheEntry] = [:]
    private static let cacheMaxSize = 50
    private static let cacheExpiration: TimeInterval = 86400

    public init(client: GeminiClient) {
        self.client = client
    }

    public init(configuration: GeminiConfiguration = GeminiConfiguration()) {
        self.client = GeminiClient(configuration: configuration)
    }

    /// 텍스트 설명으로 영양 정보 추정
    public func estimateNutrition(from text: String) async throws -> NutritionEstimationResult {
        // 입력 길이 제한
        let sanitizedText = Self.sanitizeInput(text)
        guard !sanitizedText.isEmpty else {
            throw NutritionEstimationError.invalidResponse
        }

        // Cache lookup
        let cacheKey = sanitizedText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if let entry = cache[cacheKey],
           Date().timeIntervalSince(entry.timestamp) < Self.cacheExpiration {
            return entry.result
        }

        let response = try await client.generateContent(
            systemPrompt: NutritionPrompts.textNutritionSystemPrompt,
            userMessage: NutritionPrompts.textNutritionUserPrompt(foodDescription: sanitizedText),
            model: .flash,
            temperature: 0.3,
            maxTokens: 1500
        )

        guard let content = response.text else {
            throw NutritionEstimationError.noResponse
        }

        let result = try parseNutritionResponse(content)

        // Only cache successful responses (skip error responses)
        if result.error == nil {
            if cache.count >= Self.cacheMaxSize,
               let oldestKey = cache.min(by: { $0.value.timestamp < $1.value.timestamp })?.key {
                cache.removeValue(forKey: oldestKey)
            }
            cache[cacheKey] = CacheEntry(result: result, timestamp: Date())
        }

        return result
    }

    /// 입력 텍스트 정제 (길이 제한 + 제어 문자 제거)
    private static func sanitizeInput(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let limited = String(trimmed.prefix(maxInputLength))
        // 제어 문자 제거 (줄바꿈, 탭 제외)
        return limited.unicodeScalars.filter { scalar in
            scalar == "\n" || scalar == "\t" || !CharacterSet.controlCharacters.contains(scalar)
        }.map(String.init).joined()
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
            let result = try decoder.decode(NutritionEstimationResult.self, from: data)
            return Self.validateResponse(result)
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

    /// 응답 값 범위 검증 및 보정
    private static func validateResponse(_ result: NutritionEstimationResult) -> NutritionEstimationResult {
        let validatedFoods = result.foods.map { food in
            EstimatedFood(
                name: String(food.name.prefix(100)),
                servingSize: clamp(food.servingSize, min: 0, max: 10000),
                servingUnit: String(food.servingUnit.prefix(20)),
                calories: clamp(food.calories, min: 0, max: 10000),
                protein: clamp(food.protein, min: 0, max: 1000),
                carbs: clamp(food.carbs, min: 0, max: 1000),
                fat: clamp(food.fat, min: 0, max: 1000),
                fiber: food.fiber.map { clamp($0, min: 0, max: 500) },
                sodium: food.sodium.map { clamp($0, min: 0, max: 50000) },
                sugar: food.sugar.map { clamp($0, min: 0, max: 500) },
                confidence: clamp(food.confidence, min: 0, max: 1),
                estimatedPortion: food.estimatedPortion.map { String($0.prefix(100)) }
            )
        }

        let validatedTotalCalories = clamp(result.totalCalories, min: 0, max: 50000)

        return NutritionEstimationResult(
            foods: validatedFoods,
            totalCalories: validatedTotalCalories,
            mealDescription: result.mealDescription.map { String($0.prefix(500)) },
            healthTip: result.healthTip.map { String($0.prefix(500)) },
            portionNotes: result.portionNotes.map { String($0.prefix(500)) },
            error: result.error
        )
    }

    private static func clamp(_ value: Int, min: Int, max: Int) -> Int {
        Swift.max(min, Swift.min(max, value))
    }

    private static func clamp(_ value: Double, min: Double, max: Double) -> Double {
        Swift.max(min, Swift.min(max, value))
    }

    private func extractJSON(from text: String) -> String {
        // JSON 블록 찾기
        if let jsonStart = text.range(of: "{"),
           let jsonEnd = text.range(of: "}", options: .backwards) {
            return String(text[jsonStart.lowerBound..<jsonEnd.upperBound])
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
            return NSLocalizedString("error.ai.noResponse", comment: "No AI response")
        case .invalidResponse:
            return NSLocalizedString("error.ai.invalidFormat", comment: "Invalid response format")
        case .parsingFailed(let detail):
            return String(
                format: NSLocalizedString("error.ai.parseFailed", comment: "Parse failed: %@"),
                detail
            )
        case .imageProcessingFailed:
            return NSLocalizedString("error.ai.imageFailed", comment: "Image processing failed")
        }
    }
}
