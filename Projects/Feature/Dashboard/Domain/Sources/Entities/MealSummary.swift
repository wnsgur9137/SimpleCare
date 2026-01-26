//
//  MealSummary.swift
//  DashboardDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// 식사 타입
public enum DashboardMealType: String, Codable, CaseIterable, Sendable {
    case breakfast
    case lunch
    case dinner
    case snack

    public var displayName: String {
        switch self {
        case .breakfast: return "아침"
        case .lunch: return "점심"
        case .dinner: return "저녁"
        case .snack: return "간식"
        }
    }

    public var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        case .snack: return "leaf.fill"
        }
    }
}

/// 식사 요약 정보
public struct MealSummary: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let mealType: DashboardMealType
    public let foodNames: [String]
    public let totalCalories: Int
    public let recordedAt: Date

    public init(
        id: UUID = UUID(),
        mealType: DashboardMealType,
        foodNames: [String],
        totalCalories: Int,
        recordedAt: Date
    ) {
        self.id = id
        self.mealType = mealType
        self.foodNames = foodNames
        self.totalCalories = totalCalories
        self.recordedAt = recordedAt
    }

    /// 음식 이름을 쉼표로 연결한 문자열
    public var foodNamesText: String {
        foodNames.joined(separator: ", ")
    }
}
