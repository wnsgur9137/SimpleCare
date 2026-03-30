import SwiftUI
import ActivityKit

struct MealLiveActivityBannerView: View {
    let context: ActivityViewContext<MealRecordingAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("🍽 \(context.attributes.mealType) 기록 중")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Spacer()
                Text("\(context.state.foodCount)개 음식")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                Text("\(context.state.totalCalories) kcal")
                    .font(.system(size: 22, weight: .bold, design: .rounded))

                Spacer()

                HStack(spacing: 10) {
                    MacroLabel(label: "P", value: context.state.protein, color: .blue)
                    MacroLabel(label: "C", value: context.state.carbs, color: .orange)
                    MacroLabel(label: "F", value: context.state.fat, color: .yellow)
                }
            }

            ProgressView(value: Double(context.state.totalCalories), total: Double(max(context.state.mealCalorieGoal, 1)))
                .tint(.green)
        }
    }
}

// Shared helper for macro labels
struct MacroLabel: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text("\(Int(value))g")
                .font(.system(size: 11, weight: .medium, design: .rounded))
        }
    }
}
