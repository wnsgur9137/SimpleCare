//
//  FoodItemModel.swift
//  StorageInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import SwiftData

/// 영양 정보 소스
public enum NutritionSource: String, Codable {
    case aiEstimated = "ai_estimated"      // AI 추정
    case manual = "manual"                  // 수동 입력
    case database = "database"              // 데이터베이스
    case barcode = "barcode"                // 바코드 스캔
}

/// 음식 항목 모델
@Model
public final class FoodItemModel {
    /// 고유 식별자
    @Attribute(.unique)
    public var id: UUID

    /// 음식 이름
    public var name: String

    /// 브랜드/제조사 (선택)
    public var brand: String?

    /// 1회 제공량
    public var servingSize: Double

    /// 제공량 단위 (g, ml, 개, etc.)
    public var servingUnit: String

    /// 실제 먹은 양 (제공량 기준)
    public var quantity: Double

    /// 칼로리 (1회 제공량 기준)
    public var caloriesPerServing: Int

    /// 단백질 (g, 1회 제공량 기준)
    public var proteinPerServing: Double

    /// 탄수화물 (g, 1회 제공량 기준)
    public var carbsPerServing: Double

    /// 지방 (g, 1회 제공량 기준)
    public var fatPerServing: Double

    /// 식이섬유 (g, 1회 제공량 기준, 선택)
    public var fiberPerServing: Double?

    /// 나트륨 (mg, 1회 제공량 기준, 선택)
    public var sodiumPerServing: Double?

    /// 당류 (g, 1회 제공량 기준, 선택)
    public var sugarPerServing: Double?

    /// 영양 정보 출처
    public var nutritionSource: NutritionSource

    /// AI 추정 신뢰도 (0.0 ~ 1.0)
    public var aiConfidence: Double?

    /// 관련 식사 기록
    @Relationship(inverse: \MealRecordModel.foodItems)
    public var mealRecord: MealRecordModel?

    /// 생성 일시
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        brand: String? = nil,
        servingSize: Double = 100,
        servingUnit: String = "g",
        quantity: Double = 1.0,
        caloriesPerServing: Int,
        proteinPerServing: Double,
        carbsPerServing: Double,
        fatPerServing: Double,
        fiberPerServing: Double? = nil,
        sodiumPerServing: Double? = nil,
        sugarPerServing: Double? = nil,
        nutritionSource: NutritionSource = .manual,
        aiConfidence: Double? = nil,
        mealRecord: MealRecordModel? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.servingSize = servingSize
        self.servingUnit = servingUnit
        self.quantity = quantity
        self.caloriesPerServing = caloriesPerServing
        self.proteinPerServing = proteinPerServing
        self.carbsPerServing = carbsPerServing
        self.fatPerServing = fatPerServing
        self.fiberPerServing = fiberPerServing
        self.sodiumPerServing = sodiumPerServing
        self.sugarPerServing = sugarPerServing
        self.nutritionSource = nutritionSource
        self.aiConfidence = aiConfidence
        self.mealRecord = mealRecord
        self.createdAt = createdAt
    }

    /// 실제 섭취 칼로리
    public var calories: Int {
        Int(Double(caloriesPerServing) * quantity)
    }

    /// 실제 섭취 단백질
    public var proteinGrams: Double {
        proteinPerServing * quantity
    }

    /// 실제 섭취 탄수화물
    public var carbsGrams: Double {
        carbsPerServing * quantity
    }

    /// 실제 섭취 지방
    public var fatGrams: Double {
        fatPerServing * quantity
    }

    /// 표시용 문자열 (예: "100g x 1.5")
    public var servingDescription: String {
        let sizeStr = servingSize.truncatingRemainder(dividingBy: 1) == 0 ?
            String(format: "%.0f", servingSize) :
            String(format: "%.1f", servingSize)
        let qtyStr = quantity.truncatingRemainder(dividingBy: 1) == 0 ?
            String(format: "%.0f", quantity) :
            String(format: "%.1f", quantity)

        if quantity == 1.0 {
            return "\(sizeStr)\(servingUnit)"
        } else {
            return "\(sizeStr)\(servingUnit) x \(qtyStr)"
        }
    }
}
