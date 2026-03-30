import ActivityKit
import WidgetKit
import SwiftUI

struct ExerciseRecordingLiveActivity: Widget {
    let kind = "ExerciseRecordingLiveActivity"

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ExerciseRecordingAttributes.self) { context in
            // Lock Screen Banner
            ExerciseLiveActivityBannerView(context: context)
                .padding(16)
                .activityBackgroundTint(.green.opacity(0.1))
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.exerciseType)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                        Text(context.attributes.intensity)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 4) {
                        Text(context.attributes.startTime, style: .timer)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        Text("🔥 \(context.state.estimatedCalories) kcal 소모")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("\(context.state.estimatedCalories) kcal 소모")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Text("🏃")
                    .font(.system(size: 14))
            } compactTrailing: {
                Text(context.attributes.startTime, style: .timer)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .monospacedDigit()
            } minimal: {
                Text("🏃")
                    .font(.system(size: 12))
            }
        }
    }
}
