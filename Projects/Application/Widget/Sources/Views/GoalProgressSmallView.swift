//
//  GoalProgressSmallView.swift
//  SimpleCareWidget
//
//  Created by SimpleCare on 3/23/26.
//

import SwiftUI
import WidgetKit

// MARK: - GoalProgressSmallView

/// 소형 위젯: 목표 달성률 + 연속 기록
struct GoalProgressSmallView: View {

    let entry: WidgetEntry

    // MARK: - Private Helpers

    private var progressPercent: String {
        String(format: "%.0f", entry.calorieProgress * 100)
    }

    private var currentProgressColor: Color {
        progressColor(for: entry.calorieProgress)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            percentSection

            Spacer()

            achievementLabel

            Spacer()

            streakSection

            Spacer()
        }
        .padding(12)
        .if(entry.isPlaceholder) { view in
            view.redacted(reason: .placeholder)
        }
    }

    // MARK: - Subviews

    private var percentSection: some View {
        HStack(alignment: .lastTextBaseline, spacing: 2) {
            Text(progressPercent)
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundStyle(currentProgressColor)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Text("%")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(currentProgressColor.opacity(0.8))
        }
    }

    private var achievementLabel: some View {
        Text("달성률")
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundStyle(.secondary)
    }

    private var streakSection: some View {
        HStack(spacing: 4) {
            Text("\u{1F525}") // 🔥
                .font(.system(size: 14))

            Text("\(entry.streakDays)일 연속")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.orange)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.orange.opacity(0.12))
        )
    }
}


// MARK: - Preview

#Preview("GoalProgressSmall — 정상", as: .systemSmall) {
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

#Preview("GoalProgressSmall — 달성", as: .systemSmall) {
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

#Preview("GoalProgressSmall — 플레이스홀더", as: .systemSmall) {
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
