import ActivityKit
import Foundation

struct MealRecordingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var totalCalories: Int
        var mealCalorieGoal: Int
        var protein: Double
        var carbs: Double
        var fat: Double
        var foodCount: Int
    }

    var mealType: String
    var startTime: Date
}
