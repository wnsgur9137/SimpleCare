//
//  WaterIntakeInteractiveView.swift
//  SimpleCareWidget
//
//  Created by SimpleCare on 3/30/26.
//

import SwiftUI
import WidgetKit
import AppIntents

// MARK: - WaterIntakeInteractiveView

/// Interactive 수분 섭취 위젯 (Small) - 버튼으로 1잔 추가
struct WaterIntakeInteractiveView: View {

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

    // MARK: - Body

    var body: some View {
        VStack(spacing: 4) {
            titleLabel
            circularProgress
            addButton
        }
        .padding(10)
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
                .stroke(Color.secondary.opacity(0.2), lineWidth: 6)

            // 프로그레스 아크
            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(
                    currentProgressColor,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // 내부 텍스트
            VStack(spacing: 1) {
                Text("\(entry.waterIntakeCups)/\(entry.waterGoalCups)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Text("잔")
                    .font(.system(size: 8, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var addButton: some View {
        Button(intent: AddWaterIntent()) {
            Text("+ 1잔")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(currentProgressColor)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("WaterIntakeInteractive — 정상", as: .systemSmall) {
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

#Preview("WaterIntakeInteractive — 목표 달성", as: .systemSmall) {
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
