//
//  DailyCalorieMediumView.swift
//  SimpleCareWidget
//
//  Created by SimpleCare on 3/23/26.
//

import SwiftUI
import WidgetKit

// MARK: - DailyCalorieMediumView

/// 중형 위젯: 일일 칼로리 원형 프로그레스 + 상세 정보
struct DailyCalorieMediumView: View {

    let entry: WidgetEntry

    // MARK: - Private Helpers

    private var progressColor: Color {
        caloriProgressColor(entry.calorieProgress)
    }

    private var clampedProgress: Double {
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
        ZStack {
            // 배경 트랙
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: 10)

            // 프로그레스 아크
            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.4), value: clampedProgress)

            // 내부 텍스트
            VStack(spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(entry.totalCalories)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)

                    Text("/\(entry.goalCalories)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }

                Text("kcal")
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
    }

    // MARK: - Right Section

    private var rightSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            detailRow(
                title: "운동 소모",
                value: "\(entry.exerciseCalories) kcal",
                valueColor: .blue
            )

            detailRow(
                title: "남은 칼로리",
                value: "\(entry.remainingCalories) kcal",
                valueColor: progressColor
            )

            detailRow(
                title: "진행률",
                value: progressPercent,
                valueColor: progressColor
            )
        }
        .padding(.leading, 12)
    }

    private func detailRow(title: String, value: String, valueColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(valueColor)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
    }
}

// MARK: - Progress Color Helper

private func caloriProgressColor(_ progress: Double) -> Color {
    if progress < 0.8 {
        return .orange
    } else if progress <= 1.1 {
        return .green
    } else {
        return .red
    }
}

// MARK: - View Extension

private extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Preview

#Preview("DailyCalorieMedium — 정상", as: .systemMedium) {
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

#Preview("DailyCalorieMedium — 달성", as: .systemMedium) {
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

#Preview("DailyCalorieMedium — 플레이스홀더", as: .systemMedium) {
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
