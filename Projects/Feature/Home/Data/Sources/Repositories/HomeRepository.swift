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
    private let mealStorage: MealRecordRepository
    private let exerciseStorage: ExerciseRecordRepository

    public init(
        mealStorage: MealRecordRepository = MealRecordRepository(),
        exerciseStorage: ExerciseRecordRepository = ExerciseRecordRepository()
    ) {
        self.mealStorage = mealStorage
        self.exerciseStorage = exerciseStorage
    }

    public func getDailySummary(date: Date, userProfileId: UUID, goalCalories: Int) async throws -> HomeDailySummary {
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
            streakDays: streakDays
        )
    }

    // MARK: - Private

    /// 연속 기록 일수 계산 (오늘부터 과거로 연속된 날 수)
    private func calculateStreakDays(userProfileId: UUID, from date: Date) async throws -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = date

        for _ in 0..<30 {
            let meals = try await mealStorage.fetchMeals(for: currentDate, userProfileId: userProfileId)
            let exercises = try await exerciseStorage.fetchExercises(for: currentDate, userProfileId: userProfileId)

            if meals.isEmpty && exercises.isEmpty {
                break
            }

            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
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
