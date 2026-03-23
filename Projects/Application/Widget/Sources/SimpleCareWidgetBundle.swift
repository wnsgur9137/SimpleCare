import WidgetKit
import SwiftUI

@main
struct SimpleCareWidgetBundle: WidgetBundle {
    var body: some Widget {
        DailyCalorieWidget()
        GoalProgressWidget()
    }
}
