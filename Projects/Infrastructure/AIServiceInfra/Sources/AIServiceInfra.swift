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
// - OpenAIClient: Core client for OpenAI API communication
// - OpenAIConfiguration: API configuration (key, model, etc.)
// - NutritionEstimationService: Text/image-based nutrition analysis
// - DailyInsightService: Daily meal insights generation
//
// Usage:
// ```swift
// import AIServiceInfra
//
// // Text-based nutrition estimation
// let service = NutritionEstimationService()
// let result = try await service.estimateNutrition(from: "치킨 샐러드 1인분")
//
// // Image-based analysis
// let imageResult = try await service.analyzeImage(imageData)
// ```
//
// Note: Requires OPENAI_API_KEY in Info.plist or environment variable
