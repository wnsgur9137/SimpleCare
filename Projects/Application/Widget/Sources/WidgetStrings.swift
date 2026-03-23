import Foundation

// MARK: - Widget Localization Keys

enum WidgetStrings {
    // DailyCalorieWidget
    static let dailyCalorieTitle = String(localized: "widget.dailyCalorie.title")
    static let dailyCalorieDescription = String(localized: "widget.dailyCalorie.description")
    static let remaining = String(localized: "widget.remaining")
    static let exerciseBurned = String(localized: "widget.exerciseBurned")
    static let remainingCalories = String(localized: "widget.remainingCalories")
    static let progressRate = String(localized: "widget.progressRate")

    // GoalProgressWidget
    static let goalProgressTitle = String(localized: "widget.goalProgress.title")
    static let goalProgressDescription = String(localized: "widget.goalProgress.description")
    static let achievementRate = String(localized: "widget.achievementRate")

    // Common
    static func streakDays(_ count: Int) -> String {
        String(format: String(localized: "widget.streakDays"), count)
    }
}
