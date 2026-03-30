import SwiftUI
import WidgetKit

struct LockScreenInlineView: View {
    let entry: WidgetEntry

    var body: some View {
        Text("🔥 \(entry.streakDays)일 · \(entry.remainingCalories) kcal 남음")
    }
}

// MARK: - Preview

#Preview("LockScreenInline", as: .accessoryInline) {
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
