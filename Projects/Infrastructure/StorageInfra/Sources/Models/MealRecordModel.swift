//
//  MealRecordModel.swift
//  StorageInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import SwiftData

/// 식사 유형
public enum MealType: String, Codable, CaseIterable {
    case breakfast = "breakfast"  // 아침
    case lunch = "lunch"          // 점심
    case dinner = "dinner"        // 저녁
    case snack = "snack"          // 간식

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
        case .dinner: return "sunset.fill"
        case .snack: return "leaf.fill"
        }
    }
}

/// 식사 기록 모델
@Model
public final class MealRecordModel {
    /// 고유 식별자
    @Attribute(.unique)
    public var id: UUID

    /// 사용자 프로필 ID
    public var userProfileId: UUID

    /// 식사 유형
    public var mealType: MealType

    /// 기록 날짜
    public var date: Date

    /// 음식 항목들
    @Relationship(deleteRule: .cascade)
    public var foodItems: [FoodItemModel]

    /// 식사 메모
    public var notes: String?

    /// 사진 데이터 (저장된 이미지 경로)
    public var imageDataPath: String?

    /// 생성 일시
    public var createdAt: Date

    /// 수정 일시
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        userProfileId: UUID,
        mealType: MealType,
        date: Date = Date(),
        foodItems: [FoodItemModel] = [],
        notes: String? = nil,
        imageDataPath: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userProfileId = userProfileId
        self.mealType = mealType
        self.date = date
        self.foodItems = foodItems
        self.notes = notes
        self.imageDataPath = imageDataPath
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// 총 칼로리
    public var totalCalories: Int {
        foodItems.reduce(0) { $0 + $1.calories }
    }

    /// 총 단백질 (g)
    public var totalProtein: Double {
        foodItems.reduce(0.0) { $0 + $1.proteinGrams }
    }

    /// 총 탄수화물 (g)
    public var totalCarbs: Double {
        foodItems.reduce(0.0) { $0 + $1.carbsGrams }
    }

    /// 총 지방 (g)
    public var totalFat: Double {
        foodItems.reduce(0.0) { $0 + $1.fatGrams }
    }
}
