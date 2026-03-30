import ActivityKit
import WidgetKit
import SwiftUI

struct MealRecordingLiveActivity: Widget {
    let kind = "MealRecordingLiveActivity"

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MealRecordingAttributes.self) { context in
            // Lock Screen Banner
            MealLiveActivityBannerView(context: context)
                .padding(16)
                .activityBackgroundTint(.blue.opacity(0.1))
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.mealType)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.foodCount)개")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 4) {
                        Text("\(context.state.totalCalories) kcal")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        HStack(spacing: 12) {
                            MacroLabel(label: "P", value: context.state.protein, color: .blue)
                            MacroLabel(label: "C", value: context.state.carbs, color: .orange)
                            MacroLabel(label: "F", value: context.state.fat, color: .yellow)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: Double(context.state.totalCalories), total: Double(max(context.state.mealCalorieGoal, 1)))
                        .tint(.green)
                }
            } compactLeading: {
                Text("🍽")
                    .font(.system(size: 14))
            } compactTrailing: {
                Text("\(context.state.totalCalories)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            } minimal: {
                Text("🍽")
                    .font(.system(size: 12))
            }
        }
    }
}
