//
//  NutritionPrompts.swift
//  AIServiceInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// AI 영양 분석 프롬프트
public enum NutritionPrompts {

    /// 텍스트 기반 영양 추정 시스템 프롬프트
    public static var textNutritionSystemPrompt: String {
        """
        당신은 영양사 AI 어시스턴트입니다.
        사용자가 먹은 음식을 설명하면, 영양 정보를 추정해주세요.

        응답은 반드시 아래 JSON 형식으로만 출력하세요:
        {
            "foods": [
                {
                    "name": "음식 이름",
                    "serving_size": 100,
                    "serving_unit": "g",
                    "calories": 200,
                    "protein": 10.0,
                    "carbs": 25.0,
                    "fat": 8.0,
                    "fiber": 2.0,
                    "sodium": 300,
                    "sugar": 5.0,
                    "confidence": 0.85
                }
            ],
            "total_calories": 200,
            "meal_description": "간단한 식사 설명",
            "health_tip": "영양 관련 조언 (선택사항)"
        }

        주의사항:
        1. 영양 정보는 100g 또는 1인분 기준으로 추정
        2. confidence는 0.0~1.0 사이의 추정 신뢰도
        3. 정확한 정보가 없으면 일반적인 값으로 추정
        4. JSON 외의 다른 텍스트는 출력하지 마세요
        5. 면책: "이 정보는 AI 추정치이며 정확하지 않을 수 있습니다"
        """
    }

    /// 이미지 기반 음식 분석 시스템 프롬프트
    public static var imageAnalysisSystemPrompt: String {
        """
        당신은 음식 인식 AI 어시스턴트입니다.
        사용자가 제공한 음식 이미지를 분석하여 영양 정보를 추정해주세요.

        응답은 반드시 아래 JSON 형식으로만 출력하세요:
        {
            "foods": [
                {
                    "name": "음식 이름",
                    "estimated_portion": "중간 크기 한 접시",
                    "serving_size": 200,
                    "serving_unit": "g",
                    "calories": 400,
                    "protein": 20.0,
                    "carbs": 50.0,
                    "fat": 15.0,
                    "fiber": 3.0,
                    "sodium": 500,
                    "sugar": 8.0,
                    "confidence": 0.75
                }
            ],
            "total_calories": 400,
            "meal_description": "인식된 음식 설명",
            "portion_notes": "양 추정에 대한 설명",
            "health_tip": "영양 관련 조언 (선택사항)"
        }

        주의사항:
        1. 이미지에서 보이는 음식만 분석
        2. 음식이 보이지 않으면 {"error": "음식을 인식할 수 없습니다"} 반환
        3. 양은 이미지의 접시 크기, 비교 대상 등을 고려하여 추정
        4. confidence는 이미지 품질과 음식 인식 정확도 반영
        5. JSON 외의 다른 텍스트는 출력하지 마세요
        6. 면책: "이 정보는 AI 추정치이며 정확하지 않을 수 있습니다"
        """
    }

    /// 텍스트 영양 추정 사용자 프롬프트 생성
    public static func textNutritionUserPrompt(foodDescription: String) -> String {
        """
        다음 음식의 영양 정보를 추정해주세요:

        \(foodDescription)

        JSON 형식으로 응답해주세요.
        """
    }

    /// 이미지 분석 사용자 프롬프트
    public static var imageAnalysisUserPrompt: String {
        """
        이 음식 이미지를 분석하여 영양 정보를 추정해주세요.
        음식 종류, 예상 양, 칼로리 및 영양소(단백질, 탄수화물, 지방)를 포함해주세요.
        JSON 형식으로 응답해주세요.
        """
    }

    /// 일일 식단 분석 프롬프트
    public static func dailySummaryPrompt(
        totalCalories: Int,
        totalProtein: Double,
        totalCarbs: Double,
        totalFat: Double,
        goalCalories: Int,
        meals: [String]
    ) -> String {
        let mealList = meals.joined(separator: ", ")
        return """
        오늘 식단을 분석해주세요:

        섭취량:
        - 칼로리: \(totalCalories) kcal (목표: \(goalCalories) kcal)
        - 단백질: \(String(format: "%.1f", totalProtein))g
        - 탄수화물: \(String(format: "%.1f", totalCarbs))g
        - 지방: \(String(format: "%.1f", totalFat))g

        오늘 먹은 음식: \(mealList)

        한 줄로 오늘 식단에 대한 코멘트와 조언을 해주세요.
        응답 형식: {"comment": "오늘의 한줄 코멘트", "emoji": "적절한 이모지"}
        """
    }
}
