import SwiftUI
import WidgetKit

struct LockScreenRectangularView: View {
    let entry: WidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("🍽 \(entry.totalCalories)/\(entry.goalCalories) kcal")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text("P \(Int(entry.totalProtein))g  C \(Int(entry.totalCarbs))g  F \(Int(entry.totalFat))g")
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text("🔥 \(entry.streakDays)일 연속")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview("LockScreenRectangular — 정상", as: .accessoryRectangular) {
    LockScreenWidget()
} timeline: {
    WidgetEntry(
        date: .now,
        totalCalories: 1_450,
        goalCalories: 2_000,
        remainingCalories: 550,
        calorieProgress: 0.73,
        exerciseCalories: 320,
        totalProtein: 72,
        totalCarbs: 180,
        totalFat: 45,
        proteinGoal: 120,
        carbsGoal: 250,
        fatGoal: 65,
        streakDays: 7,
        isPlaceholder: false
    )
}

#Preview("LockScreenRectangular — 초과", as: .accessoryRectangular) {
    LockScreenWidget()
} timeline: {
    WidgetEntry(
        date: .now,
        totalCalories: 2_200,
        goalCalories: 2_000,
        remainingCalories: -200,
        calorieProgress: 1.10,
        exerciseCalories: 250,
        totalProtein: 120,
        totalCarbs: 280,
        totalFat: 70,
        proteinGoal: 120,
        carbsGoal: 250,
        fatGoal: 65,
        streakDays: 3,
        isPlaceholder: false
    )
}
