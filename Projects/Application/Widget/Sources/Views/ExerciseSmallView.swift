//
//  ExerciseSmallView.swift
//  SimpleCareWidget
//

import SwiftUI
import WidgetKit

// MARK: - ExerciseSmallView

/// 소형 위젯: 오늘의 운동 세션 수, 총 칼로리 소모, 주간 스트릭
struct ExerciseSmallView: View {

    let entry: WidgetEntry

    // MARK: - Private Helpers

    private var weeklyProgress: Double {
        guard entry.weeklyExerciseGoal > 0 else { return 0 }
        return Double(entry.weeklyExerciseDays) / Double(entry.weeklyExerciseGoal)
    }

    private var streakColor: Color {
        progressColor(for: weeklyProgress)
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            titleLabel
            Spacer(minLength: 0)
            statsSection
            Spacer(minLength: 0)
            weeklyStreakBadge
        }
        .padding(12)
        .if(entry.isPlaceholder) { view in
            view.redacted(reason: .placeholder)
        }
    }

    // MARK: - Subviews

    private var titleLabel: some View {
        Text("🏃 오늘의 운동")
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(.secondary)
            .lineLimit(1)
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text("\(entry.exerciseSessions)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Text("세션")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text("\(entry.exerciseCalories)")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.blue)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Text("kcal 소모")
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var weeklyStreakBadge: some View {
        HStack(spacing: 4) {
            Text("주간")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)

            Text("\(entry.weeklyExerciseDays)/\(entry.weeklyExerciseGoal)일")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(streakColor)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(streakColor.opacity(0.15))
                .clipShape(Capsule())
        }
    }
}


// MARK: - Preview

#Preview("ExerciseSmall — 정상", as: .systemSmall) {
    ExerciseWidget()
} timeline: {
    WidgetEntry(
        date: .now,
        totalCalories: 1_450,
        goalCalories: 2_000,
        remainingCalories: 550,
        calorieProgress: 0.725,
        exerciseCalories: 320,
        totalProtein: 72,
        totalCarbs: 180,
        totalFat: 45,
        proteinGoal: 120,
        carbsGoal: 250,
        fatGoal: 65,
        streakDays: 5,
        isPlaceholder: false,
        exerciseSessions: 2,
        exerciseDuration: 45,
        weeklyExerciseDays: 3,
        weeklyExerciseGoal: 5,
        recentExercises: [("달리기", 180), ("스쿼트", 140)]
    )
}

#Preview("ExerciseSmall — 고활동", as: .systemSmall) {
    ExerciseWidget()
} timeline: {
    WidgetEntry(
        date: .now,
        totalCalories: 1_800,
        goalCalories: 2_000,
        remainingCalories: 200,
        calorieProgress: 0.9,
        exerciseCalories: 650,
        totalProtein: 110,
        totalCarbs: 200,
        totalFat: 55,
        proteinGoal: 120,
        carbsGoal: 250,
        fatGoal: 65,
        streakDays: 10,
        isPlaceholder: false,
        exerciseSessions: 4,
        exerciseDuration: 90,
        weeklyExerciseDays: 5,
        weeklyExerciseGoal: 5,
        recentExercises: [("사이클링", 300), ("수영", 250)]
    )
}

#Preview("ExerciseSmall — 플레이스홀더", as: .systemSmall) {
    ExerciseWidget()
} timeline: {
    WidgetEntry(
        date: .now,
        totalCalories: 0,
        goalCalories: 2_000,
        remainingCalories: 2_000,
        calorieProgress: 0,
        exerciseCalories: 0,
        totalProtein: 0,
        totalCarbs: 0,
        totalFat: 0,
        proteinGoal: 120,
        carbsGoal: 250,
        fatGoal: 65,
        streakDays: 0,
        isPlaceholder: true,
        exerciseSessions: 0,
        exerciseDuration: 0,
        weeklyExerciseDays: 0,
        weeklyExerciseGoal: 5,
        recentExercises: []
    )
}
