import Foundation

/// Widget Extension과 메인 앱 간 공유 데이터 모델
public struct WidgetDailySummaryData: Codable, Sendable {
    public let date: Date
    public let totalCalories: Int
    public let goalCalories: Int
    public let remainingCalories: Int
    public let calorieProgress: Double
    public let exerciseCalories: Int
    public let totalProtein: Double
    public let totalCarbs: Double
    public let totalFat: Double
    public let proteinGoal: Double
    public let carbsGoal: Double
    public let fatGoal: Double
    public let streakDays: Int
    public let lastUpdated: Date

    public init(
        date: Date,
        totalCalories: Int,
        goalCalories: Int,
        remainingCalories: Int,
        calorieProgress: Double,
        exerciseCalories: Int,
        totalProtein: Double,
        totalCarbs: Double,
        totalFat: Double,
        proteinGoal: Double,
        carbsGoal: Double,
        fatGoal: Double,
        streakDays: Int,
        lastUpdated: Date = Date()
    ) {
        self.date = date
        self.totalCalories = totalCalories
        self.goalCalories = goalCalories
        self.remainingCalories = remainingCalories
        self.calorieProgress = calorieProgress
        self.exerciseCalories = exerciseCalories
        self.totalProtein = totalProtein
        self.totalCarbs = totalCarbs
        self.totalFat = totalFat
        self.proteinGoal = proteinGoal
        self.carbsGoal = carbsGoal
        self.fatGoal = fatGoal
        self.streakDays = streakDays
        self.lastUpdated = lastUpdated
    }
}
