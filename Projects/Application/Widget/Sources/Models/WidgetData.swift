import WidgetKit
import Foundation

struct WidgetEntry: TimelineEntry {
    // MARK: - Calorie
    let date: Date
    let totalCalories: Int
    let goalCalories: Int
    let remainingCalories: Int
    let calorieProgress: Double
    let exerciseCalories: Int

    // MARK: - Macros
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double
    let proteinGoal: Double
    let carbsGoal: Double
    let fatGoal: Double

    // MARK: - Streak
    let streakDays: Int
    let isPlaceholder: Bool

    // MARK: - Exercise (W-A1)
    let exerciseSessions: Int
    let exerciseDuration: Int
    let weeklyExerciseDays: Int
    let weeklyExerciseGoal: Int
    let recentExercises: [(name: String, calories: Int)]

    // MARK: - Weight (W-A2)
    let currentWeight: Double?
    let targetWeight: Double?
    let weightChange7d: Double?
    let bmi: Double?
    let recentWeights: [(date: Date, weight: Double)]

    // MARK: - Water (W-A3)
    let waterIntakeCups: Int
    let waterGoalCups: Int
    let waterIntakeML: Int

    // MARK: - Init (new fields have defaults for backward compat)

    init(
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
        isPlaceholder: Bool,
        exerciseSessions: Int = 0,
        exerciseDuration: Int = 0,
        weeklyExerciseDays: Int = 0,
        weeklyExerciseGoal: Int = 5,
        recentExercises: [(name: String, calories: Int)] = [],
        currentWeight: Double? = nil,
        targetWeight: Double? = nil,
        weightChange7d: Double? = nil,
        bmi: Double? = nil,
        recentWeights: [(date: Date, weight: Double)] = [],
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
        self.isPlaceholder = isPlaceholder
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
        isPlaceholder: true,
        exerciseSessions: 2,
        exerciseDuration: 45,
        weeklyExerciseDays: 3,
        weeklyExerciseGoal: 5,
        recentExercises: [("달리기", 180), ("스쿼트", 140)],
        currentWeight: 72.5,
        targetWeight: 70.0,
        weightChange7d: -0.8,
        bmi: 23.1,
        waterIntakeCups: 6,
        waterGoalCups: 8,
        waterIntakeML: 1500
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
