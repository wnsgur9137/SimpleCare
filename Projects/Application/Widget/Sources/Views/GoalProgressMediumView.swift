//
//  GoalProgressMediumView.swift
//  SimpleCareWidget
//
//  Created by SimpleCare on 3/23/26.
//

import SwiftUI
import WidgetKit

// MARK: - GoalProgressMediumView

/// 중형 위젯: 칼로리 달성률 원형 프로그레스 + 영양소 프로그레스 바
struct GoalProgressMediumView: View {

    let entry: WidgetEntry

    // MARK: - Private Helpers

    private var currentProgressColor: Color {
        progressColor(for: entry.calorieProgress)
    }

    private var clampedCalorieProgress: Double {
        min(entry.calorieProgress, 1.0)
    }

    private var progressPercent: String {
        String(format: "%.0f%%", entry.calorieProgress * 100)
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
        VStack(spacing: 6) {
            ZStack {
                // 배경 트랙
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 9)

                // 프로그레스 아크
                Circle()
                    .trim(from: 0, to: clampedCalorieProgress)
                    .stroke(
                        currentProgressColor,
                        style: StrokeStyle(lineWidth: 9, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.4), value: clampedCalorieProgress)

                // 내부 퍼센트 텍스트
                VStack(spacing: 1) {
                    Text(progressPercent)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(currentProgressColor)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)

                    Text(WidgetStrings.achievementRate)
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(8)
        }
    }

    // MARK: - Right Section

    private var rightSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            nutritionRow(
                label: "P",
                current: entry.totalProtein,
                goal: entry.proteinGoal,
                color: .blue
            )

            nutritionRow(
                label: "C",
                current: entry.totalCarbs,
                goal: entry.carbsGoal,
                color: .orange
            )

            nutritionRow(
                label: "F",
                current: entry.totalFat,
                goal: entry.fatGoal,
                color: .yellow
            )

            Spacer(minLength: 0)

            streakBadge
        }
        .padding(.leading, 12)
    }

    // MARK: - Nutrition Row

    private func nutritionRow(
        label: String,
        current: Double,
        goal: Double,
        color: Color
    ) -> some View {
        let progress = goal > 0 ? min(current / goal, 1.0) : 0.0

        return VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                    .frame(width: 14, alignment: .leading)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(color)
                            .frame(width: geometry.size.width * progress, height: 6)
                            .animation(.easeOut(duration: 0.35), value: progress)
                    }
                }
                .frame(height: 6)
            }

            Text("\(Int(current)) / \(Int(goal))g")
                .font(.system(size: 9, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.leading, 18)
        }
    }

    // MARK: - Streak Badge

    private var streakBadge: some View {
        HStack(spacing: 3) {
            Text("\u{1F525}") // 🔥
                .font(.system(size: 11))

            Text(WidgetStrings.streakDays(entry.streakDays))
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.orange)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.widgetWarning.opacity(0.12))
        )
    }
}


// MARK: - Preview

#Preview("GoalProgressMedium — 정상", as: .systemMedium) {
    GoalProgressWidget()
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
        streakDays: 7,
        isPlaceholder: false
    )
}

#Preview("GoalProgressMedium — 달성", as: .systemMedium) {
    GoalProgressWidget()
} timeline: {
    WidgetEntry(
        date: .now,
        totalCalories: 2_050,
        goalCalories: 2_000,
        remainingCalories: -50,
        calorieProgress: 1.025,
        exerciseCalories: 400,
        totalProtein: 115,
        totalCarbs: 240,
        totalFat: 62,
        proteinGoal: 120,
        carbsGoal: 250,
        fatGoal: 65,
        streakDays: 30,
        isPlaceholder: false
    )
}

#Preview("GoalProgressMedium — 초과", as: .systemMedium) {
    GoalProgressWidget()
} timeline: {
    WidgetEntry(
        date: .now,
        totalCalories: 2_500,
        goalCalories: 2_000,
        remainingCalories: -500,
        calorieProgress: 1.25,
        exerciseCalories: 200,
        totalProtein: 155,
        totalCarbs: 320,
        totalFat: 90,
        proteinGoal: 120,
        carbsGoal: 250,
        fatGoal: 65,
        streakDays: 3,
        isPlaceholder: false
    )
}

#Preview("GoalProgressMedium — 플레이스홀더", as: .systemMedium) {
    GoalProgressWidget()
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
        isPlaceholder: true
    )
}
