import SwiftUI
import ActivityKit

struct ExerciseLiveActivityBannerView: View {
    let context: ActivityViewContext<ExerciseRecordingAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("🏃 \(context.attributes.exerciseType) (\(context.attributes.intensity))")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Spacer()
            }

            Text(context.attributes.startTime, style: .timer)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .monospacedDigit()

            HStack {
                Text("🔥 \(context.state.estimatedCalories) kcal 소모")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
    }
}
