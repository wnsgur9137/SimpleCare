//
//  AIServiceInfra.swift
//  AIServiceInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

// MARK: - Public Exports

// This module provides AI service integration for nutrition analysis.
//
// Main components:
// - GeminiClient: Core client for Google Gemini API communication
// - GeminiConfiguration: API configuration (key, model, etc.)
// - NutritionEstimationService: Text-based nutrition analysis
// - DailyInsightService: Daily meal insights generation
//
// Usage:
// ```swift
// import AIServiceInfra
//
// // Text-based nutrition estimation
// let service = NutritionEstimationService()
// let result = try await service.estimateNutrition(from: "치킨 샐러드 1인분")
// ```
//
// Note: Requires GEMINI_API_KEY in Info.plist or Keychain
