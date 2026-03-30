import SwiftUI
import WidgetKit

struct LockScreenCircularView: View {
    let entry: WidgetEntry

    var body: some View {
        Gauge(value: min(entry.calorieProgress, 1.0)) {
            Text("kcal")
                .font(.system(size: 8))
        } currentValueLabel: {
            Text("\(min(Int(entry.calorieProgress * 100), 100))")
                .font(.system(size: 16, weight: .bold, design: .rounded))
        }
        .gaugeStyle(.accessoryCircular)
    }
}

// MARK: - Preview

#Preview("LockScreenCircular — 73%", as: .accessoryCircular) {
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

#Preview("LockScreenCircular — 초과", as: .accessoryCircular) {
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
