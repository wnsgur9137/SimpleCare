//
//  FavoriteFoodModel.swift
//  StorageInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import SwiftData

/// 즐겨찾기 음식 모델
@Model
public final class FavoriteFoodModel {
    /// 고유 식별자
    @Attribute(.unique)
    public var id: UUID

    /// 사용자 프로필 ID
    public var userProfileId: UUID

    /// 음식 이름
    public var name: String

    /// 브랜드/제조사 (선택)
    public var brand: String?

    /// 1회 제공량
    public var servingSize: Double

    /// 제공량 단위 (g, ml, 개, etc.)
    public var servingUnit: String

    /// 칼로리 (1회 제공량 기준)
    public var caloriesPerServing: Int

    /// 단백질 (g, 1회 제공량 기준)
    public var proteinPerServing: Double

    /// 탄수화물 (g, 1회 제공량 기준)
    public var carbsPerServing: Double

    /// 지방 (g, 1회 제공량 기준)
    public var fatPerServing: Double

    /// 식이섬유 (g, 선택)
    public var fiberPerServing: Double?

    /// 나트륨 (mg, 선택)
    public var sodiumPerServing: Double?

    /// 당류 (g, 선택)
    public var sugarPerServing: Double?

    /// 사용 횟수 (정렬용)
    public var usageCount: Int

    /// 마지막 사용 일시
    public var lastUsedAt: Date?

    /// 생성 일시
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        userProfileId: UUID,
        name: String,
        brand: String? = nil,
        servingSize: Double = 100,
        servingUnit: String = "g",
        caloriesPerServing: Int,
        proteinPerServing: Double,
        carbsPerServing: Double,
        fatPerServing: Double,
        fiberPerServing: Double? = nil,
        sodiumPerServing: Double? = nil,
        sugarPerServing: Double? = nil,
        usageCount: Int = 0,
        lastUsedAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userProfileId = userProfileId
        self.name = name
        self.brand = brand
        self.servingSize = servingSize
        self.servingUnit = servingUnit
        self.caloriesPerServing = caloriesPerServing
        self.proteinPerServing = proteinPerServing
        self.carbsPerServing = carbsPerServing
        self.fatPerServing = fatPerServing
        self.fiberPerServing = fiberPerServing
        self.sodiumPerServing = sodiumPerServing
        self.sugarPerServing = sugarPerServing
        self.usageCount = usageCount
        self.lastUsedAt = lastUsedAt
        self.createdAt = createdAt
    }

    /// FoodItemModel로 변환
    public func toFoodItem(quantity: Double = 1.0) -> FoodItemModel {
        return FoodItemModel(
            name: name,
            brand: brand,
            servingSize: servingSize,
            servingUnit: servingUnit,
            quantity: quantity,
            caloriesPerServing: caloriesPerServing,
            proteinPerServing: proteinPerServing,
            carbsPerServing: carbsPerServing,
            fatPerServing: fatPerServing,
            fiberPerServing: fiberPerServing,
            sodiumPerServing: sodiumPerServing,
            sugarPerServing: sugarPerServing,
            nutritionSource: .database
        )
    }

    /// 사용 시 호출하여 카운트 증가
    public func recordUsage() {
        usageCount += 1
        lastUsedAt = Date()
    }

    /// 표시용 제공량 문자열
    public var servingDescription: String {
        let sizeStr = servingSize.truncatingRemainder(dividingBy: 1) == 0 ?
            String(format: "%.0f", servingSize) :
            String(format: "%.1f", servingSize)
        return "\(sizeStr)\(servingUnit)"
    }
}
