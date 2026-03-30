//
//  WaterIntakeSmallView.swift
//  SimpleCareWidget
//
//  Created by SimpleCare on 3/30/26.
//

import SwiftUI
import WidgetKit

// MARK: - WaterIntakeSmallView

/// 소형 위젯: 수분 섭취 원형 프로그레스
struct WaterIntakeSmallView: View {

    let entry: WidgetEntry

    // MARK: - Private Helpers

    private var waterProgress: Double {
        guard entry.waterGoalCups > 0 else { return 0 }
        return Double(entry.waterIntakeCups) / Double(entry.waterGoalCups)
    }

    private var clampedProgress: Double {
        min(waterProgress, 1.0)
    }

    private var currentProgressColor: Color {
        if waterProgress >= 1.0 {
            return .cyan
        } else if waterProgress >= 0.5 {
            return .blue
        } else {
            return .blue.opacity(0.6)
        }
    }

    private var percentageText: String {
        let pct = Int((waterProgress * 100).rounded())
        return "\(min(pct, 100))%"
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 6) {
            titleLabel
            circularProgress
            percentageLabel
        }
        .padding(12)
        .if(entry.isPlaceholder) { view in
            view.redacted(reason: .placeholder)
        }
    }

    // MARK: - Subviews

    private var titleLabel: some View {
        Text("💧 수분 섭취")
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

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
                    Text("\(entry.waterIntakeCups)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)

                    Text("/\(entry.waterGoalCups)")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }

                Text("잔")
                    .font(.system(size: 9, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var percentageLabel: some View {
        Text(percentageText)
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .foregroundStyle(currentProgressColor)
            .minimumScaleFactor(0.7)
            .lineLimit(1)
    }
}

// MARK: - Preview

#Preview("WaterIntakeSmall — 정상", as: .systemSmall) {
    WaterIntakeWidget()
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
        waterIntakeCups: 6,
        waterGoalCups: 8,
        waterIntakeML: 1500
    )
}

#Preview("WaterIntakeSmall — 목표 달성", as: .systemSmall) {
    WaterIntakeWidget()
} timeline: {
    WidgetEntry(
        date: .now,
        totalCalories: 1_800,
        goalCalories: 2_000,
        remainingCalories: 200,
        calorieProgress: 0.9,
        exerciseCalories: 250,
        totalProtein: 90,
        totalCarbs: 210,
        totalFat: 55,
        proteinGoal: 120,
        carbsGoal: 250,
        fatGoal: 65,
        streakDays: 8,
        isPlaceholder: false,
        waterIntakeCups: 8,
        waterGoalCups: 8,
        waterIntakeML: 2000
    )
}

#Preview("WaterIntakeSmall — 플레이스홀더", as: .systemSmall) {
    WaterIntakeWidget()
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
        waterIntakeCups: 0,
        waterGoalCups: 8,
        waterIntakeML: 0
    )
}
