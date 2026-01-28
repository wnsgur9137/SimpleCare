//
//  HomeDailySummary.swift
//  HomeDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// 홈 화면용 하루 요약 정보
public struct HomeDailySummary: Equatable, Sendable {
    public let date: Date
    public let totalCalories: Int
    public let goalCalories: Int
    public let totalProtein: Double
    public let totalCarbs: Double
    public let totalFat: Double
    public let exerciseCalories: Int
    public let meals: [HomeMealSummary]
    public let exercises: [HomeExerciseSummary]
    public let streakDays: Int
    public let proteinGoal: Double
    public let carbsGoal: Double
    public let fatGoal: Double

    public init(
        date: Date,
        totalCalories: Int,
        goalCalories: Int,
        totalProtein: Double,
        totalCarbs: Double,
        totalFat: Double,
        exerciseCalories: Int = 0,
        meals: [HomeMealSummary] = [],
        exercises: [HomeExerciseSummary] = [],
        streakDays: Int = 0,
        proteinGoal: Double = 100,
        carbsGoal: Double = 250,
        fatGoal: Double = 70
    ) {
        self.date = date
        self.totalCalories = totalCalories
        self.goalCalories = goalCalories
        self.totalProtein = totalProtein
        self.totalCarbs = totalCarbs
        self.totalFat = totalFat
        self.exerciseCalories = exerciseCalories
        self.meals = meals
        self.exercises = exercises
        self.streakDays = streakDays
        self.proteinGoal = proteinGoal
        self.carbsGoal = carbsGoal
        self.fatGoal = fatGoal
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
    public var calorieStatus: HomeCalorieStatus {
        let progress = calorieProgress
        if progress < 0.8 {
            return .under
        } else if progress <= 1.1 {
            return .onTrack
        } else {
            return .over
        }
    }

    /// 기록이 있는지 여부
    public var hasRecords: Bool {
        !meals.isEmpty || !exercises.isEmpty
    }

    /// 단백질 달성률
    public var proteinProgress: Double {
        guard proteinGoal > 0 else { return 0 }
        return min(totalProtein / proteinGoal, 1.0)
    }

    /// 탄수화물 달성률
    public var carbsProgress: Double {
        guard carbsGoal > 0 else { return 0 }
        return min(totalCarbs / carbsGoal, 1.0)
    }

    /// 지방 달성률
    public var fatProgress: Double {
        guard fatGoal > 0 else { return 0 }
        return min(totalFat / fatGoal, 1.0)
    }

    /// 빈 요약
    public static func empty(goalCalories: Int) -> HomeDailySummary {
        HomeDailySummary(
            date: Date(),
            totalCalories: 0,
            goalCalories: goalCalories,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0
        )
    }
}

/// 칼로리 상태
public enum HomeCalorieStatus: Equatable, Sendable {
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
}

/// AI 인사이트
public struct HomeInsight: Equatable, Sendable {
    public let comment: String
    public let emoji: String

    public init(comment: String, emoji: String) {
        self.comment = comment
        self.emoji = emoji
    }

    public static var defaultInsight: HomeInsight {
        HomeInsight(
            comment: "오늘도 건강한 하루를 시작해보세요!",
            emoji: "💪"
        )
    }
}
