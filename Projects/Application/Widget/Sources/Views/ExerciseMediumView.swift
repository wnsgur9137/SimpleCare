//
//  ExerciseMediumView.swift
//  SimpleCareWidget
//

import SwiftUI
import WidgetKit

// MARK: - ExerciseMediumView

/// 중형 위젯: 운동 세션/칼로리/시간 + 최근 운동 목록 + 주간 스트릭
struct ExerciseMediumView: View {

    let entry: WidgetEntry

    // MARK: - Private Helpers

    private var weeklyProgress: Double {
        guard entry.weeklyExerciseGoal > 0 else { return 0 }
        return Double(entry.weeklyExerciseDays) / Double(entry.weeklyExerciseGoal)
    }

    private var streakColor: Color {
        progressColor(for: weeklyProgress)
    }

    private var recentExercisesSlice: [(name: String, calories: Int)] {
        Array(entry.recentExercises.prefix(2))
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            leftSection
                .frame(maxWidth: .infinity)

            Divider()
                .padding(.vertical, 12)

            rightSection
                .frame(maxWidth: .infinity)
        }
        .padding(14)
        .if(entry.isPlaceholder) { view in
            view.redacted(reason: .placeholder)
        }
    }

    // MARK: - Left Section

    private var leftSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("🏃 오늘의 운동")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            statRow(
                value: "\(entry.exerciseSessions)세션",
                label: "총 운동",
                valueColor: .primary
            )

            statRow(
                value: "\(entry.exerciseCalories) kcal",
                label: "소모 칼로리",
                valueColor: .blue
            )

            statRow(
                value: "\(entry.exerciseDuration)분",
                label: "운동 시간",
                valueColor: .orange
            )
        }
        .padding(.trailing, 12)
    }

    private func statRow(value: String, label: String, valueColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(valueColor)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
    }

    // MARK: - Right Section

    private var rightSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            recentExercisesSection
            Spacer(minLength: 0)
            weeklyStreakBadge
        }
        .padding(.leading, 12)
    }

    private var recentExercisesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("최근 운동")
                .font(.system(size: 10, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)

            if recentExercisesSlice.isEmpty {
                Text("기록 없음")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.tertiary)
            } else {
                ForEach(recentExercisesSlice.indices, id: \.self) { index in
                    exerciseRow(recentExercisesSlice[index])
                }
            }
        }
    }

    private func exerciseRow(_ exercise: (name: String, calories: Int)) -> some View {
        HStack(spacing: 4) {
            Text(exercise.name)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Spacer(minLength: 4)

            Text("\(exercise.calories) kcal")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.blue)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
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

#Preview("ExerciseMedium — 정상", as: .systemMedium) {
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

#Preview("ExerciseMedium — 고활동", as: .systemMedium) {
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

#Preview("ExerciseMedium — 플레이스홀더", as: .systemMedium) {
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
