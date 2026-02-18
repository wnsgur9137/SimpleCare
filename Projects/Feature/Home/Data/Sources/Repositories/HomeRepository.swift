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
public final class HomeRepository: HomeDailySummaryRepositoryProtocol, @unchecked Sendable {
    private let maxStreakCheckDays = 30
    private let mealStorage: MealRecordRepository
    private let exerciseStorage: ExerciseRecordRepository

    public init(
        mealStorage: MealRecordRepository = MealRecordRepository(),
        exerciseStorage: ExerciseRecordRepository = ExerciseRecordRepository()
    ) {
        self.mealStorage = mealStorage
        self.exerciseStorage = exerciseStorage
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
        HomeExerciseSummary(
            id: id,
            exerciseName: exerciseType.displayName,
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
