import WidgetKit
import BaseDomain

struct WidgetDataProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        let entry = loadCurrentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let entry = loadCurrentEntry()

        // 다음 갱신: 30분 후
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        // 자정에도 갱신 (날짜 변경)
        let midnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        )
        let earlierDate = min(nextUpdate, midnight)

        let timeline = Timeline(entries: [entry], policy: .after(earlierDate))
        completion(timeline)
    }

    private func loadCurrentEntry() -> WidgetEntry {
        guard let data = WidgetDataStore.load() else {
            return .empty
        }

        // 날짜가 오늘이 아니면 빈 데이터
        guard Calendar.current.isDateInToday(data.date) else {
            return .empty
        }

        let pendingWaterCups = WidgetDataStore.sharedDefaults?.integer(forKey: WidgetConstants.waterPendingCupsKey) ?? 0
        let totalWaterCups = data.waterIntakeCups + pendingWaterCups

        return WidgetEntry(
            date: data.date,
            totalCalories: data.totalCalories,
            goalCalories: data.goalCalories,
            remainingCalories: data.remainingCalories,
            calorieProgress: data.calorieProgress,
            exerciseCalories: data.exerciseCalories,
            totalProtein: data.totalProtein,
            totalCarbs: data.totalCarbs,
            totalFat: data.totalFat,
            proteinGoal: data.proteinGoal,
            carbsGoal: data.carbsGoal,
            fatGoal: data.fatGoal,
            streakDays: data.streakDays,
            isPlaceholder: false,
            exerciseSessions: data.exerciseSessions,
            exerciseDuration: data.exerciseDuration,
            weeklyExerciseDays: data.weeklyExerciseDays,
            weeklyExerciseGoal: data.weeklyExerciseGoal,
            recentExercises: data.recentExercises.map { ($0.name, $0.calories) },
            currentWeight: data.currentWeight,
            targetWeight: data.targetWeight,
            weightChange7d: data.weightChange7d,
            bmi: data.bmi,
            recentWeights: data.recentWeights.map { ($0.date, $0.weight) },
            waterIntakeCups: totalWaterCups,
            waterGoalCups: data.waterGoalCups,
            waterIntakeML: data.waterIntakeML
        )
    }
}
