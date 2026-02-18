//
//  HomeReport.swift
//  HomeDomain
//
//  Created by SimpleCare on 2/18/26.
//

import Foundation

/// 주간 리포트
public struct WeeklyReport: Equatable, Sendable {
    public let weekStartDate: Date
    public let avgDailyCalories: Int
    public let totalExerciseMinutes: Int
    public let totalExerciseCalories: Int
    public let weightChange: Double?
    public let streakDays: Int
    public let dailyCalories: [Int]
    public let goalCalories: Int
    public let topExercises: [ExerciseStat]

    public init(
        weekStartDate: Date,
        avgDailyCalories: Int,
        totalExerciseMinutes: Int,
        totalExerciseCalories: Int,
        weightChange: Double?,
        streakDays: Int,
        dailyCalories: [Int],
        goalCalories: Int,
        topExercises: [ExerciseStat] = []
    ) {
        self.weekStartDate = weekStartDate
        self.avgDailyCalories = avgDailyCalories
        self.totalExerciseMinutes = totalExerciseMinutes
        self.totalExerciseCalories = totalExerciseCalories
        self.weightChange = weightChange
        self.streakDays = streakDays
        self.dailyCalories = dailyCalories
        self.goalCalories = goalCalories
        self.topExercises = topExercises
    }

    /// 목표 달성률 (평균 칼로리 기준)
    public var goalAchievementRate: Double {
        guard goalCalories > 0 else { return 0 }
        return Double(avgDailyCalories) / Double(goalCalories)
    }
}

/// 월간 리포트
public struct MonthlyReport: Equatable, Sendable {
    public let monthDate: Date
    public let avgDailyCalories: Int
    public let totalExerciseMinutes: Int
    public let weightChange: Double?
    public let weeklyCalorieTrend: [Int]
    public let macroAverage: MacroAverage
    public let goalCalories: Int
    public let recordedDays: Int

    public init(
        monthDate: Date,
        avgDailyCalories: Int,
        totalExerciseMinutes: Int,
        weightChange: Double?,
        weeklyCalorieTrend: [Int],
        macroAverage: MacroAverage,
        goalCalories: Int,
        recordedDays: Int = 0
    ) {
        self.monthDate = monthDate
        self.avgDailyCalories = avgDailyCalories
        self.totalExerciseMinutes = totalExerciseMinutes
        self.weightChange = weightChange
        self.weeklyCalorieTrend = weeklyCalorieTrend
        self.macroAverage = macroAverage
        self.goalCalories = goalCalories
        self.recordedDays = recordedDays
    }

    /// 목표 달성률
    public var goalAchievementRate: Double {
        guard goalCalories > 0 else { return 0 }
        return Double(avgDailyCalories) / Double(goalCalories)
    }
}

/// 운동 통계
public struct ExerciseStat: Equatable, Sendable {
    public let name: String
    public let count: Int

    public init(name: String, count: Int) {
        self.name = name
        self.count = count
    }
}

/// 매크로 평균
public struct MacroAverage: Equatable, Sendable {
    public let protein: Double
    public let carbs: Double
    public let fat: Double

    public init(protein: Double, carbs: Double, fat: Double) {
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }

    /// 전체 그램 합계
    public var total: Double {
        protein + carbs + fat
    }

    /// 단백질 비율
    public var proteinRatio: Double {
        guard total > 0 else { return 0 }
        return protein / total
    }

    /// 탄수화물 비율
    public var carbsRatio: Double {
        guard total > 0 else { return 0 }
        return carbs / total
    }

    /// 지방 비율
    public var fatRatio: Double {
        guard total > 0 else { return 0 }
        return fat / total
    }
}
