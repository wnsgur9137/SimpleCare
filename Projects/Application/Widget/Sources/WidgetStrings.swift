import Foundation

// MARK: - Widget Localization Keys

enum WidgetStrings {
    // MARK: - DailyCalorieWidget
    static let dailyCalorieTitle = String(localized: "widget.dailyCalorie.title")
    static let dailyCalorieDescription = String(localized: "widget.dailyCalorie.description")
    static let remaining = String(localized: "widget.remaining")
    static let exerciseBurned = String(localized: "widget.exerciseBurned")
    static let remainingCalories = String(localized: "widget.remainingCalories")
    static let progressRate = String(localized: "widget.progressRate")

    // MARK: - GoalProgressWidget
    static let goalProgressTitle = String(localized: "widget.goalProgress.title")
    static let goalProgressDescription = String(localized: "widget.goalProgress.description")
    static let achievementRate = String(localized: "widget.achievementRate")

    // MARK: - ExerciseWidget (W-A1)
    static let exerciseTitle = String(localized: "widget.exercise.title")
    static let exerciseDescription = String(localized: "widget.exercise.description")
    static let todayExercise = String(localized: "widget.exercise.today")
    static let sessions = String(localized: "widget.exercise.sessions")
    static let duration = String(localized: "widget.exercise.duration")
    static let caloriesBurned = String(localized: "widget.exercise.caloriesBurned")
    static let recentExercises = String(localized: "widget.exercise.recent")
    static func weeklyProgress(_ current: Int, _ goal: Int) -> String {
        String(format: String(localized: "widget.exercise.weeklyProgress"), current, goal)
    }

    // MARK: - WeightTrendWidget (W-A2)
    static let weightTitle = String(localized: "widget.weight.title")
    static let weightDescription = String(localized: "widget.weight.description")
    static let currentWeight = String(localized: "widget.weight.current")
    static let targetWeight = String(localized: "widget.weight.target")
    static let weightChange = String(localized: "widget.weight.change")
    static let toGoal = String(localized: "widget.weight.toGoal")

    // MARK: - WaterIntakeWidget (W-A3)
    static let waterTitle = String(localized: "widget.water.title")
    static let waterDescription = String(localized: "widget.water.description")
    static let cups = String(localized: "widget.water.cups")
    static let addOneCup = String(localized: "widget.water.addOne")

    // MARK: - WeightQuickInputWidget (W-D2)
    static let weightQuickInputTitle = String(localized: "widget.weightQuickInput.title")
    static let weightQuickInputDescription = String(localized: "widget.weightQuickInput.description")

    // MARK: - LockScreenWidget (W-B2)
    static let lockScreenTitle = String(localized: "widget.lockScreen.title")
    static let lockScreenDescription = String(localized: "widget.lockScreen.description")

    // MARK: - Live Activity (W-C1, W-C2)
    static let mealRecording = String(localized: "widget.liveActivity.mealRecording")
    static let exerciseRecording = String(localized: "widget.liveActivity.exerciseRecording")
    static func foodCount(_ count: Int) -> String {
        String(format: String(localized: "widget.liveActivity.foodCount"), count)
    }

    // MARK: - Common
    static func streakDays(_ count: Int) -> String {
        String(format: String(localized: "widget.streakDays"), count)
    }
}
