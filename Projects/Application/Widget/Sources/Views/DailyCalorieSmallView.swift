//
//  DailyCalorieSmallView.swift
//  SimpleCareWidget
//
//  Created by SimpleCare on 3/23/26.
//

import SwiftUI
import WidgetKit

// MARK: - DailyCalorieSmallView

/// 소형 위젯: 일일 칼로리 원형 프로그레스
struct DailyCalorieSmallView: View {

    let entry: WidgetEntry

    // MARK: - Private Helpers

    private var currentProgressColor: Color {
        progressColor(for: entry.calorieProgress)
    }

    private var clampedProgress: Double {
        min(entry.calorieProgress, 1.0)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 6) {
            circularProgress
            remainingLabel
        }
        .padding(12)
        .if(entry.isPlaceholder) { view in
            view.redacted(reason: .placeholder)
        }
    }

    // MARK: - Subviews

    private var circularProgress: some View {
        ZStack {
            // 배경 트랙
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: 8)

            // 프로그레스 아크
            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(
                    currentProgressColor,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.4), value: clampedProgress)

            // 내부 텍스트
            VStack(spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(entry.totalCalories)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)

                    Text("/\(entry.goalCalories)")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }

                Text("kcal")
                    .font(.system(size: 9, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var remainingLabel: some View {
        HStack(spacing: 3) {
            Text("남은:")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)

            Text("\(entry.remainingCalories) kcal")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(currentProgressColor)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
    }
}


// MARK: - Preview

#Preview("DailyCalorieSmall — 정상", as: .systemSmall) {
    DailyCalorieWidget()
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
        isPlaceholder: false
    )
}

#Preview("DailyCalorieSmall — 달성", as: .systemSmall) {
    DailyCalorieWidget()
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
        streakDays: 12,
        isPlaceholder: false
    )
}

#Preview("DailyCalorieSmall — 초과", as: .systemSmall) {
    DailyCalorieWidget()
} timeline: {
    WidgetEntry(
        date: .now,
        totalCalories: 2_500,
        goalCalories: 2_000,
        remainingCalories: -500,
        calorieProgress: 1.25,
        exerciseCalories: 200,
        totalProtein: 130,
        totalCarbs: 310,
        totalFat: 80,
        proteinGoal: 120,
        carbsGoal: 250,
        fatGoal: 65,
        streakDays: 3,
        isPlaceholder: false
    )
}

#Preview("DailyCalorieSmall — 플레이스홀더", as: .systemSmall) {
    DailyCalorieWidget()
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
