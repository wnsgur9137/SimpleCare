import Foundation

/// Widget Extension과 메인 앱 간 공유 데이터 모델
public struct WidgetDailySummaryData: Codable, Sendable {
    // MARK: - Calorie
    public let date: Date
    public let totalCalories: Int
    public let goalCalories: Int
    public let remainingCalories: Int
    public let calorieProgress: Double
    public let exerciseCalories: Int

    // MARK: - Macros
    public let totalProtein: Double
    public let totalCarbs: Double
    public let totalFat: Double
    public let proteinGoal: Double
    public let carbsGoal: Double
    public let fatGoal: Double

    // MARK: - Streak
    public let streakDays: Int
    public let lastUpdated: Date

    // MARK: - Exercise (W-A1)
    public let exerciseSessions: Int
    public let exerciseDuration: Int
    public let weeklyExerciseDays: Int
    public let weeklyExerciseGoal: Int
    public let recentExercises: [WidgetExerciseItem]

    // MARK: - Weight (W-A2)
    public let currentWeight: Double?
    public let targetWeight: Double?
    public let weightChange7d: Double?
    public let bmi: Double?
    public let recentWeights: [WidgetWeightPoint]

    // MARK: - Water (W-A3)
    public let waterIntakeCups: Int
    public let waterGoalCups: Int
    public let waterIntakeML: Int

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
        lastUpdated: Date = Date(),
        exerciseSessions: Int = 0,
        exerciseDuration: Int = 0,
        weeklyExerciseDays: Int = 0,
        weeklyExerciseGoal: Int = 5,
        recentExercises: [WidgetExerciseItem] = [],
        currentWeight: Double? = nil,
        targetWeight: Double? = nil,
        weightChange7d: Double? = nil,
        bmi: Double? = nil,
        recentWeights: [WidgetWeightPoint] = [],
        waterIntakeCups: Int = 0,
        waterGoalCups: Int = 8,
        waterIntakeML: Int = 0
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
        self.exerciseSessions = exerciseSessions
        self.exerciseDuration = exerciseDuration
        self.weeklyExerciseDays = weeklyExerciseDays
        self.weeklyExerciseGoal = weeklyExerciseGoal
        self.recentExercises = recentExercises
        self.currentWeight = currentWeight
        self.targetWeight = targetWeight
        self.weightChange7d = weightChange7d
        self.bmi = bmi
        self.recentWeights = recentWeights
        self.waterIntakeCups = waterIntakeCups
        self.waterGoalCups = waterGoalCups
        self.waterIntakeML = waterIntakeML
    }
}

// MARK: - Exercise Widget Item

public struct WidgetExerciseItem: Codable, Sendable {
    public let name: String
    public let calories: Int

    public init(name: String, calories: Int) {
        self.name = name
        self.calories = calories
    }
}

// MARK: - Weight Widget Point

public struct WidgetWeightPoint: Codable, Sendable {
    public let date: Date
    public let weight: Double

    public init(date: Date, weight: Double) {
        self.date = date
        self.weight = weight
    }
}
