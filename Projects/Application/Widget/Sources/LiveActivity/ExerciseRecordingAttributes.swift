import ActivityKit
import Foundation

struct ExerciseRecordingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var elapsedSeconds: Int
        var estimatedCalories: Int
    }

    var exerciseType: String
    var intensity: String
    var metValue: Double
    var startTime: Date
}
