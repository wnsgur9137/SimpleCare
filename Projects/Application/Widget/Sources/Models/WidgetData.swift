import WidgetKit
import Foundation

struct WidgetEntry: TimelineEntry {
    let date: Date
    let totalCalories: Int
    let goalCalories: Int
    let remainingCalories: Int
    let calorieProgress: Double
    let exerciseCalories: Int
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double
    let proteinGoal: Double
    let carbsGoal: Double
    let fatGoal: Double
    let streakDays: Int
    let isPlaceholder: Bool

    static let placeholder = WidgetEntry(
        date: Date(),
        totalCalories: 1200,
        goalCalories: 2000,
        remainingCalories: 800,
        calorieProgress: 0.6,
        exerciseCalories: 320,
        totalProtein: 65,
        totalCarbs: 150,
        totalFat: 40,
        proteinGoal: 100,
        carbsGoal: 250,
        fatGoal: 70,
        streakDays: 7,
        isPlaceholder: true
    )

    static let empty = WidgetEntry(
        date: Date(),
        totalCalories: 0,
        goalCalories: 2000,
        remainingCalories: 2000,
        calorieProgress: 0,
        exerciseCalories: 0,
        totalProtein: 0,
        totalCarbs: 0,
        totalFat: 0,
        proteinGoal: 100,
        carbsGoal: 250,
        fatGoal: 70,
        streakDays: 0,
        isPlaceholder: false
    )
}
