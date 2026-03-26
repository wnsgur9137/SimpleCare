//
//  UserProfile.swift
//  ProfileDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import BaseDomain

/// 사용자 프로필 엔티티
public struct UserProfile: Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var heightCm: Double
    public var currentWeightKg: Double
    public var targetWeightKg: Double
    public var age: Int
    public var biologicalSex: BiologicalSex
    public var activityLevel: ActivityLevel
    public var goalType: GoalType
    public var dailyCalorieGoal: Int?
    public var dailyProteinGoal: Int?
    public var dailyCarbsGoal: Int?
    public var dailyFatGoal: Int?
    public var breakfastCalorieRatio: Double {
        didSet { breakfastCalorieRatio = max(0, min(1, breakfastCalorieRatio)) }
    }
    public var lunchCalorieRatio: Double {
        didSet { lunchCalorieRatio = max(0, min(1, lunchCalorieRatio)) }
    }
    public var dinnerCalorieRatio: Double {
        didSet { dinnerCalorieRatio = max(0, min(1, dinnerCalorieRatio)) }
    }
    public var snackCalorieRatio: Double {
        didSet { snackCalorieRatio = max(0, min(1, snackCalorieRatio)) }
    }
    public var isOnboardingCompleted: Bool
    public var createdAt: Date
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
        self.breakfastCalorieRatio = max(0, min(1, breakfastCalorieRatio))
        self.lunchCalorieRatio = max(0, min(1, lunchCalorieRatio))
        self.dinnerCalorieRatio = max(0, min(1, dinnerCalorieRatio))
        self.snackCalorieRatio = max(0, min(1, snackCalorieRatio))
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
        bmr * activityLevel.multiplier
    }

    /// 목표에 따른 일일 권장 칼로리
    public var recommendedDailyCalories: Int {
        let baseTdee = tdee
        switch goalType {
        case .weightLoss:
            return Int(baseTdee - 500)
        case .weightGain:
            return Int(baseTdee + 300)
        case .maintenance:
            return Int(baseTdee)
        }
    }

    /// 실제 사용할 일일 칼로리 목표 (커스텀 또는 권장값)
    public var effectiveDailyCalorieGoal: Int {
        dailyCalorieGoal ?? recommendedDailyCalories
    }

    /// Per-meal calorie goals based on ratios
    public func mealCalorieGoal(for mealType: MealCalorieType) -> Int {
        let total = Double(effectiveDailyCalorieGoal)
        switch mealType {
        case .breakfast: return Int(total * breakfastCalorieRatio)
        case .lunch: return Int(total * lunchCalorieRatio)
        case .dinner: return Int(total * dinnerCalorieRatio)
        case .snack: return Int(total * snackCalorieRatio)
        }
    }

    /// 권장 일일 단백질 (체중 kg * 1.6g)
    public var recommendedDailyProtein: Int {
        Int(currentWeightKg * 1.6)
    }

    /// 권장 일일 탄수화물 (전체 칼로리의 50%)
    public var recommendedDailyCarbs: Int {
        Int(Double(effectiveDailyCalorieGoal) * 0.5 / 4.0)
    }

    /// 권장 일일 지방 (전체 칼로리의 25%)
    public var recommendedDailyFat: Int {
        Int(Double(effectiveDailyCalorieGoal) * 0.25 / 9.0)
    }

    /// BMI (체질량 지수) 계산
    public var bmi: Double {
        guard heightCm > 0 else { return 0 }
        let heightM = heightCm / 100.0
        return currentWeightKg / (heightM * heightM)
    }

    /// BMI 범위 라벨
    public var bmiCategory: String {
        let value = bmi
        switch value {
        case ..<18.5:
            return "weight.bmi.underweight".localized
        case 18.5..<25.0:
            return "weight.bmi.normal".localized
        case 25.0..<30.0:
            return "weight.bmi.overweight".localized
        default:
            return "weight.bmi.obese".localized
        }
    }
}

/// 성별
public enum BiologicalSex: String, Codable, CaseIterable, Sendable {
    case male
    case female

    public var displayName: String {
        switch self {
        case .male: return "profile.gender.male".localized
        case .female: return "profile.gender.female".localized
        }
    }
}

/// 활동 수준
public enum ActivityLevel: String, Codable, CaseIterable, Sendable {
    case sedentary
    case lightlyActive
    case moderatelyActive
    case veryActive
    case extraActive

    public var displayName: String {
        switch self {
        case .sedentary: return "profile.activityLevel.sedentary".localized
        case .lightlyActive: return "profile.activityLevel.lightlyActive".localized
        case .moderatelyActive: return "profile.activityLevel.moderatelyActive".localized
        case .veryActive: return "profile.activityLevel.veryActive".localized
        case .extraActive: return "profile.activityLevel.extraActive".localized
        }
    }

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

/// 목표 유형
public enum GoalType: String, Codable, CaseIterable, Sendable {
    case weightLoss
    case weightGain
    case maintenance

    public var displayName: String {
        switch self {
        case .weightLoss: return "profile.goal.weightLoss".localized
        case .weightGain: return "profile.goal.weightGain".localized
        case .maintenance: return "profile.goal.maintenance".localized
        }
    }

    public var icon: String {
        switch self {
        case .weightLoss: return "arrow.down.circle.fill"
        case .weightGain: return "arrow.up.circle.fill"
        case .maintenance: return "equal.circle.fill"
        }
    }
}

/// 식사별 칼로리 목표 계산용 유형
public enum MealCalorieType: String, CaseIterable, Sendable {
    case breakfast
    case lunch
    case dinner
    case snack
}
