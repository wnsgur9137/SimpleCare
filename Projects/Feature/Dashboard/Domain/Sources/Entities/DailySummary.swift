//
//  DailySummary.swift
//  DashboardDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// 하루 요약 정보
public struct DailySummary: Equatable, Sendable {
    public let date: Date
    public let totalCalories: Int
    public let goalCalories: Int
    public let totalProtein: Double
    public let totalCarbs: Double
    public let totalFat: Double
    public let mealCount: Int
    public let exerciseCalories: Int

    public init(
        date: Date,
        totalCalories: Int,
        goalCalories: Int,
        totalProtein: Double,
        totalCarbs: Double,
        totalFat: Double,
        mealCount: Int,
        exerciseCalories: Int = 0
    ) {
        self.date = date
        self.totalCalories = totalCalories
        self.goalCalories = goalCalories
        self.totalProtein = totalProtein
        self.totalCarbs = totalCarbs
        self.totalFat = totalFat
        self.mealCount = mealCount
        self.exerciseCalories = exerciseCalories
    }

    /// 남은 칼로리
    public var remainingCalories: Int {
        goalCalories - totalCalories + exerciseCalories
    }

    /// 칼로리 달성률 (0.0 ~ 1.0+)
    public var calorieProgress: Double {
        guard goalCalories > 0 else { return 0 }
        return Double(totalCalories) / Double(goalCalories)
    }

    /// 칼로리 상태
    public var calorieStatus: CalorieStatus {
        let progress = calorieProgress
        if progress < 0.8 {
            return .under
        } else if progress <= 1.1 {
            return .onTrack
        } else {
            return .over
        }
    }
}

/// 칼로리 상태
public enum CalorieStatus: Equatable, Sendable {
    case under
    case onTrack
    case over

    public var displayName: String {
        switch self {
        case .under: return "부족"
        case .onTrack: return "적정"
        case .over: return "초과"
        }
    }

    public var color: String {
        switch self {
        case .under: return "orange"
        case .onTrack: return "green"
        case .over: return "red"
        }
    }
}

/// AI 인사이트
public struct DailyInsight: Equatable, Sendable {
    public let comment: String
    public let emoji: String

    public init(comment: String, emoji: String) {
        self.comment = comment
        self.emoji = emoji
    }

    public static var defaultInsight: DailyInsight {
        DailyInsight(
            comment: "오늘도 건강한 식단을 위해 노력해주세요!",
            emoji: "💪"
        )
    }
}
