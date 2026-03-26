//
//  UserProfileModel.swift
//  StorageInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import SwiftData

/// 사용자의 목표 유형
public enum GoalType: String, Codable {
    case weightLoss = "weight_loss"      // 체중 감량
    case weightGain = "weight_gain"      // 체중 증가
    case maintenance = "maintenance"      // 유지
}

/// 활동 수준
public enum ActivityLevel: String, Codable {
    case sedentary = "sedentary"           // 거의 운동 안 함
    case lightlyActive = "lightly_active"  // 가벼운 활동 (주 1-3회)
    case moderatelyActive = "moderately_active"  // 중간 활동 (주 3-5회)
    case veryActive = "very_active"        // 활발한 활동 (주 6-7회)
    case extraActive = "extra_active"      // 매우 활발 (운동선수 수준)

    /// 활동 수준에 따른 TDEE 계수
    public var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive: return 1.725
        case .extraActive: return 1.9
        }
    }
}

/// 성별
public enum BiologicalSex: String, Codable {
    case male = "male"
    case female = "female"
}

/// 사용자 프로필 모델
@Model
public final class UserProfileModel {
    /// 고유 식별자
    @Attribute(.unique)
    public var id: UUID

    /// 이름
    public var name: String

    /// 키 (cm)
    public var heightCm: Double

    /// 현재 체중 (kg)
    public var currentWeightKg: Double

    /// 목표 체중 (kg)
    public var targetWeightKg: Double

    /// 나이
    public var age: Int

    /// 성별
    public var biologicalSex: BiologicalSex

    /// 활동 수준
    public var activityLevel: ActivityLevel

    /// 목표 유형
    public var goalType: GoalType

    /// 일일 목표 칼로리 (계산된 값 또는 사용자 지정)
    public var dailyCalorieGoal: Int?

    /// 일일 단백질 목표 (g)
    public var dailyProteinGoal: Int?

    /// 일일 탄수화물 목표 (g)
    public var dailyCarbsGoal: Int?

    /// 일일 지방 목표 (g)
    public var dailyFatGoal: Int?

    /// 아침 칼로리 비율
    public var breakfastCalorieRatio: Double

    /// 점심 칼로리 비율
    public var lunchCalorieRatio: Double

    /// 저녁 칼로리 비율
    public var dinnerCalorieRatio: Double

    /// 간식 칼로리 비율
    public var snackCalorieRatio: Double

    /// 온보딩 완료 여부
    public var isOnboardingCompleted: Bool

    /// 생성 일시
    public var createdAt: Date

    /// 수정 일시
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String = "",
        heightCm: Double = 170.0,
        currentWeightKg: Double = 70.0,
        targetWeightKg: Double = 65.0,
        age: Int = 30,
        biologicalSex: BiologicalSex = .male,
        activityLevel: ActivityLevel = .moderatelyActive,
        goalType: GoalType = .maintenance,
        dailyCalorieGoal: Int? = nil,
        dailyProteinGoal: Int? = nil,
        dailyCarbsGoal: Int? = nil,
        dailyFatGoal: Int? = nil,
        breakfastCalorieRatio: Double = 0.25,
        lunchCalorieRatio: Double = 0.35,
        dinnerCalorieRatio: Double = 0.30,
        snackCalorieRatio: Double = 0.10,
        isOnboardingCompleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.heightCm = heightCm
        self.currentWeightKg = currentWeightKg
        self.targetWeightKg = targetWeightKg
        self.age = age
        self.biologicalSex = biologicalSex
        self.activityLevel = activityLevel
        self.goalType = goalType
        self.dailyCalorieGoal = dailyCalorieGoal
        self.dailyProteinGoal = dailyProteinGoal
        self.dailyCarbsGoal = dailyCarbsGoal
        self.dailyFatGoal = dailyFatGoal
        self.breakfastCalorieRatio = breakfastCalorieRatio
        self.lunchCalorieRatio = lunchCalorieRatio
        self.dinnerCalorieRatio = dinnerCalorieRatio
        self.snackCalorieRatio = snackCalorieRatio
        assert(
            abs(breakfastCalorieRatio + lunchCalorieRatio + dinnerCalorieRatio + snackCalorieRatio - 1.0) < 0.001,
            "Sum of meal calorie ratios must be 1.0"
        )
        self.isOnboardingCompleted = isOnboardingCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// BMR (기초대사량) 계산 - Mifflin-St Jeor 공식
    public var bmr: Double {
        switch biologicalSex {
        case .male:
            return (10 * currentWeightKg) + (6.25 * heightCm) - (5 * Double(age)) + 5
        case .female:
            return (10 * currentWeightKg) + (6.25 * heightCm) - (5 * Double(age)) - 161
        }
    }

    /// TDEE (일일 총 에너지 소비량) 계산
    public var tdee: Double {
        return bmr * activityLevel.multiplier
    }

    /// 목표에 따른 일일 권장 칼로리
    public var recommendedDailyCalories: Int {
        let baseTdee = tdee
        switch goalType {
        case .weightLoss:
            return Int(baseTdee - 500) // 주당 약 0.5kg 감량
        case .weightGain:
            return Int(baseTdee + 300) // 주당 약 0.3kg 증량
        case .maintenance:
            return Int(baseTdee)
        }
    }
}
