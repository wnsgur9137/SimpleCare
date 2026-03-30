import WidgetKit
import SwiftUI

@main
struct SimpleCareWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Home Screen Widgets
        DailyCalorieWidget()
        GoalProgressWidget()
        ExerciseWidget()
        WeightTrendWidget()
        WaterIntakeWidget()
        WeightQuickInputWidget()

        // Lock Screen Widgets
        LockScreenWidget()

        // Live Activity
        MealRecordingLiveActivity()
        ExerciseRecordingLiveActivity()
    }
}
