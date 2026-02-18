//
//  HomeRepository.swift
//  HomeData
//
//  Created by SimpleCare on 2/15/26.
//

import Foundation
import HomeDomain
import StorageInfra

/// Home Repository 구현 - StorageInfra에서 식사/운동 데이터를 집계
public final class HomeRepository: HomeDailySummaryRepositoryProtocol, HomeReportRepositoryProtocol, @unchecked Sendable {
    private let maxStreakCheckDays = 30
    private let mealStorage: MealRecordRepository
    private let exerciseStorage: ExerciseRecordRepository
    private let weightStorage: WeightRecordRepository

    public init(
        mealStorage: MealRecordRepository = MealRecordRepository(),
        exerciseStorage: ExerciseRecordRepository = ExerciseRecordRepository(),
        weightStorage: WeightRecordRepository = WeightRecordRepository()
    ) {
        self.mealStorage = mealStorage
        self.exerciseStorage = exerciseStorage
        self.weightStorage = weightStorage
    }

    public func getDailySummary(date: Date, userProfileId: UUID, goalCalories: Int, macroGoals: MacroGoals) async throws -> HomeDailySummary {
        let meals = try await mealStorage.fetchMeals(for: date, userProfileId: userProfileId)
        let exercises = try await exerciseStorage.fetchExercises(for: date, userProfileId: userProfileId)

        let mealSummaries = meals.map { $0.toHomeMealSummary() }
        let exerciseSummaries = exercises.map { $0.toHomeExerciseSummary() }

        let totalCalories = meals.reduce(0) { $0 + $1.totalCalories }
        let totalProtein = meals.reduce(0.0) { $0 + $1.totalProtein }
        let totalCarbs = meals.reduce(0.0) { $0 + $1.totalCarbs }
        let totalFat = meals.reduce(0.0) { $0 + $1.totalFat }
        let exerciseCalories = exercises.reduce(0) { $0 + $1.caloriesBurned }

        let streakDays = try await calculateStreakDays(userProfileId: userProfileId, from: date)

        return HomeDailySummary(
            date: date,
            totalCalories: totalCalories,
            goalCalories: goalCalories,
            totalProtein: totalProtein,
            totalCarbs: totalCarbs,
            totalFat: totalFat,
            exerciseCalories: exerciseCalories,
            meals: mealSummaries,
            exercises: exerciseSummaries,
            streakDays: streakDays,
            proteinGoal: macroGoals.proteinGoal,
            carbsGoal: macroGoals.carbsGoal,
            fatGoal: macroGoals.fatGoal
        )
    }

    private static let underProgressThreshold = 0.8
    private static let onTrackProgressThreshold = 1.1

    public func getWeeklyStatus(baseDate: Date, userProfileId: UUID, goalCalories: Int) async throws -> [HomeCalorieStatus?] {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.startOfDay(for: Date())

        // Find Monday of the week containing baseDate
        let weekday = calendar.component(.weekday, from: baseDate)
        let daysFromMonday = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: baseDate)),
              let sunday = calendar.date(byAdding: .day, value: 6, to: monday) else {
            return Array(repeating: nil, count: 7)
        }

        // Fetch all data for the week at once
        async let weeklyMeals = mealStorage.fetchMeals(from: monday, to: sunday, userProfileId: userProfileId)
        async let weeklyExercises = exerciseStorage.fetchExercises(from: monday, to: sunday, userProfileId: userProfileId)

        let mealsByDay = try await Dictionary(grouping: weeklyMeals) { calendar.startOfDay(for: $0.date) }
        let exercisesByDay = try await Dictionary(grouping: weeklyExercises) { calendar.startOfDay(for: $0.date) }

        var statuses: [HomeCalorieStatus?] = []

        for dayOffset in 0..<7 {
            guard let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: monday) else {
                statuses.append(nil)
                continue
            }

            if dayDate > today {
                statuses.append(nil)
                continue
            }

            let meals = mealsByDay[dayDate] ?? []
            let exercises = exercisesByDay[dayDate] ?? []

            if meals.isEmpty && exercises.isEmpty {
                statuses.append(nil)
                continue
            }

            let totalCalories = meals.reduce(0) { $0 + $1.totalCalories }
            let progress = goalCalories > 0 ? Double(totalCalories) / Double(goalCalories) : 0

            if progress < Self.underProgressThreshold {
                statuses.append(.under)
            } else if progress <= Self.onTrackProgressThreshold {
                statuses.append(.onTrack)
            } else {
                statuses.append(.over)
            }
        }

        return statuses
    }

    // MARK: - Report

    public func getWeeklyReport(baseDate: Date, userProfileId: UUID, goalCalories: Int) async throws -> WeeklyReport {
        let calendar = Calendar(identifier: .gregorian)

        // Find Monday of the week containing baseDate
        let weekday = calendar.component(.weekday, from: baseDate)
        let daysFromMonday = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: baseDate)),
              let sundayEnd = calendar.date(byAdding: .day, value: 7, to: monday) else {
            return WeeklyReport(weekStartDate: baseDate, avgDailyCalories: 0, totalExerciseMinutes: 0, totalExerciseCalories: 0, weightChange: nil, streakDays: 0, dailyCalories: Array(repeating: 0, count: 7), goalCalories: goalCalories)
        }

        // Fetch all data for the week
        async let weeklyMeals = mealStorage.fetchMeals(from: monday, to: sundayEnd, userProfileId: userProfileId)
        async let weeklyExercises = exerciseStorage.fetchExercises(from: monday, to: sundayEnd, userProfileId: userProfileId)
        async let weeklyWeights = weightStorage.fetchWeights(from: monday, to: sundayEnd, userProfileId: userProfileId)

        let meals = try await weeklyMeals
        let exercises = try await weeklyExercises
        let weights = try await weeklyWeights

        // Daily calories (Mon-Sun)
        let mealsByDay = Dictionary(grouping: meals) { calendar.startOfDay(for: $0.date) }
        var dailyCalories: [Int] = []
        for dayOffset in 0..<7 {
            guard let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: monday) else {
                dailyCalories.append(0)
                continue
            }
            let dayMeals = mealsByDay[dayDate] ?? []
            dailyCalories.append(dayMeals.reduce(0) { $0 + $1.totalCalories })
        }

        let recordedDays = dailyCalories.filter { $0 > 0 }
        let avgCalories = recordedDays.isEmpty ? 0 : recordedDays.reduce(0, +) / recordedDays.count

        let totalExerciseMinutes = exercises.reduce(0) { $0 + $1.durationMinutes }
        let totalExerciseCalories = exercises.reduce(0) { $0 + $1.caloriesBurned }

        // Weight change (first vs last in the week)
        let weightChange: Double? = {
            guard weights.count >= 2 else { return nil }
            let sorted = weights.sorted { $0.date < $1.date }
            return sorted.last!.weightKg - sorted.first!.weightKg
        }()

        // Streak days
        let streakDays = try await calculateStreakDays(userProfileId: userProfileId, from: baseDate)

        // Top exercises
        let exerciseCounts = Dictionary(grouping: exercises) { exercise -> String in
            if exercise.exerciseType == .other, let customName = exercise.customExerciseName, !customName.isEmpty {
                return customName
            }
            return exercise.exerciseType.displayName
        }
        let topExercises = exerciseCounts
            .map { ExerciseStat(name: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
            .prefix(5)

        return WeeklyReport(
            weekStartDate: monday,
            avgDailyCalories: avgCalories,
            totalExerciseMinutes: totalExerciseMinutes,
            totalExerciseCalories: totalExerciseCalories,
            weightChange: weightChange,
            streakDays: streakDays,
            dailyCalories: dailyCalories,
            goalCalories: goalCalories,
            topExercises: Array(topExercises)
        )
    }

    public func getMonthlyReport(baseDate: Date, userProfileId: UUID, goalCalories: Int) async throws -> MonthlyReport {
        let calendar = Calendar(identifier: .gregorian)

        // Get first and last day of the month
        let components = calendar.dateComponents([.year, .month], from: baseDate)
        guard let monthStart = calendar.date(from: components),
              let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
            return MonthlyReport(monthDate: baseDate, avgDailyCalories: 0, totalExerciseMinutes: 0, weightChange: nil, weeklyCalorieTrend: [], macroAverage: MacroAverage(protein: 0, carbs: 0, fat: 0), goalCalories: goalCalories)
        }

        // Fetch all data for the month
        async let monthlyMeals = mealStorage.fetchMeals(from: monthStart, to: monthEnd, userProfileId: userProfileId)
        async let monthlyExercises = exerciseStorage.fetchExercises(from: monthStart, to: monthEnd, userProfileId: userProfileId)
        async let monthlyWeights = weightStorage.fetchWeights(from: monthStart, to: monthEnd, userProfileId: userProfileId)

        let meals = try await monthlyMeals
        let exercises = try await monthlyExercises
        let weights = try await monthlyWeights

        // Average daily calories
        let mealsByDay = Dictionary(grouping: meals) { calendar.startOfDay(for: $0.date) }
        let recordedDays = mealsByDay.count
        let totalCalories = meals.reduce(0) { $0 + $1.totalCalories }
        let avgCalories = recordedDays > 0 ? totalCalories / recordedDays : 0

        // Exercise totals
        let totalExerciseMinutes = exercises.reduce(0) { $0 + $1.durationMinutes }

        // Weight change
        let weightChange: Double? = {
            guard weights.count >= 2 else { return nil }
            let sorted = weights.sorted { $0.date < $1.date }
            return sorted.last!.weightKg - sorted.first!.weightKg
        }()

        // Weekly calorie trend (group by week of month)
        var weeklyTrend: [Int] = []
        var weekStart = monthStart
        while weekStart < monthEnd {
            guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else { break }
            let effectiveEnd = min(weekEnd, monthEnd)
            let weekMeals = meals.filter { $0.date >= weekStart && $0.date < effectiveEnd }
            let weekDays = Dictionary(grouping: weekMeals) { calendar.startOfDay(for: $0.date) }
            let weekTotal = weekMeals.reduce(0) { $0 + $1.totalCalories }
            let weekDayCount = max(weekDays.count, 1)
            weeklyTrend.append(weekTotal / weekDayCount)
            weekStart = weekEnd
        }

        // Macro average
        let totalProtein = meals.reduce(0.0) { $0 + $1.totalProtein }
        let totalCarbs = meals.reduce(0.0) { $0 + $1.totalCarbs }
        let totalFat = meals.reduce(0.0) { $0 + $1.totalFat }
        let dayCount = Double(max(recordedDays, 1))
        let macroAverage = MacroAverage(
            protein: totalProtein / dayCount,
            carbs: totalCarbs / dayCount,
            fat: totalFat / dayCount
        )

        return MonthlyReport(
            monthDate: monthStart,
            avgDailyCalories: avgCalories,
            totalExerciseMinutes: totalExerciseMinutes,
            weightChange: weightChange,
            weeklyCalorieTrend: weeklyTrend,
            macroAverage: macroAverage,
            goalCalories: goalCalories,
            recordedDays: recordedDays
        )
    }

    // MARK: - Private

    /// 연속 기록 일수 계산 (오늘부터 과거로 연속된 날 수)
    private func calculateStreakDays(userProfileId: UUID, from date: Date) async throws -> Int {
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -(maxStreakCheckDays - 1), to: date) else {
            return 0
        }

        async let meals = mealStorage.fetchMeals(from: startDate, to: date, userProfileId: userProfileId)
        async let exercises = exerciseStorage.fetchExercises(from: startDate, to: date, userProfileId: userProfileId)

        let recordedDays = try await Set(meals.map { calendar.startOfDay(for: $0.date) })
            .union(Set(exercises.map { calendar.startOfDay(for: $0.date) }))

        var streak = 0
        var currentDate = calendar.startOfDay(for: date)

        for _ in 0..<maxStreakCheckDays {
            if recordedDays.contains(currentDate) {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previousDay
            } else {
                break
            }
        }

        return streak
    }
}

// MARK: - Mapping Extensions

extension MealRecordModel {
    func toHomeMealSummary() -> HomeMealSummary {
        HomeMealSummary(
            id: id,
            mealType: mealType.toHomeMealType(),
            foodNames: foodItems.map { $0.name },
            totalCalories: totalCalories,
            recordedAt: date
        )
    }
}

extension ExerciseRecordModel {
    func toHomeExerciseSummary() -> HomeExerciseSummary {
        let name: String
        if exerciseType == .other, let customName = customExerciseName, !customName.isEmpty {
            name = customName
        } else {
            name = exerciseType.displayName
        }
        return HomeExerciseSummary(
            id: id,
            exerciseName: name,
            duration: durationMinutes,
            caloriesBurned: caloriesBurned,
            recordedAt: date
        )
    }
}

extension StorageInfra.MealType {
    func toHomeMealType() -> HomeMealType {
        switch self {
        case .breakfast: return .breakfast
        case .lunch: return .lunch
        case .dinner: return .dinner
        case .snack: return .snack
        }
    }
}
