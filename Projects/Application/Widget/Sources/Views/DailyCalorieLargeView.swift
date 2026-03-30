//
//  DailyCalorieLargeView.swift
//  SimpleCareWidget
//
//  Created by SimpleCare on 3/30/26.
//

import SwiftUI
import WidgetKit

// MARK: - DailyCalorieLargeView

/// 대형 위젯: 오늘의 종합 건강 대시보드
struct DailyCalorieLargeView: View {

    let entry: WidgetEntry

    // MARK: - Private Helpers

    private var currentProgressColor: Color {
        progressColor(for: entry.calorieProgress)
    }

    private var clampedProgress: Double {
        min(entry.calorieProgress, 1.0)
    }

    private var progressPercent: String {
        String(format: "%.0f%%", entry.calorieProgress * 100)
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: entry.date)
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleSection
                .padding(.bottom, 10)

            calorieSection
                .padding(.bottom, 12)

            sectionDivider(label: "영양소")
                .padding(.bottom, 6)

            macroSection
                .padding(.bottom, 12)

            sectionDivider(label: "오늘")
                .padding(.bottom, 6)

            todaySection
                .padding(.bottom, 12)

            streakSection
        }
        .padding(16)
        .if(entry.isPlaceholder) { view in
            view.redacted(reason: .placeholder)
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("SimpleCare")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text(dateString)
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Calorie Section

    private var calorieSection: some View {
        HStack(spacing: 14) {
            // 원형 프로그레스 (소형)
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: clampedProgress)
                    .stroke(
                        currentProgressColor,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.4), value: clampedProgress)

                VStack(spacing: 1) {
                    Text(progressPercent)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(currentProgressColor)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)

                    Text("kcal")
                        .font(.system(size: 8, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 64, height: 64)

            // 칼로리 수치
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text("\(entry.totalCalories)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)

                    Text("/ \(entry.goalCalories) kcal")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }

                HStack(spacing: 12) {
                    calorieChip(
                        label: "잔여",
                        value: "\(entry.remainingCalories) kcal",
                        color: currentProgressColor
                    )

                    calorieChip(
                        label: "운동",
                        value: "\(entry.exerciseCalories) kcal",
                        color: .blue
                    )
                }
            }

            Spacer(minLength: 0)
        }
    }

    private func calorieChip(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.system(size: 9, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
    }

    // MARK: - Section Divider

    private func sectionDivider(label: String) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            Rectangle()
                .fill(Color.secondary.opacity(0.2))
                .frame(height: 1)
        }
    }

    // MARK: - Macro Section

    private var macroSection: some View {
        VStack(alignment: .leading, spacing: 7) {
            nutritionRow(label: "P", current: entry.totalProtein, goal: entry.proteinGoal, color: .blue)
            nutritionRow(label: "C", current: entry.totalCarbs, goal: entry.carbsGoal, color: .orange)
            nutritionRow(label: "F", current: entry.totalFat, goal: entry.fatGoal, color: .yellow)
        }
    }

    private func nutritionRow(
        label: String,
        current: Double,
        goal: Double,
        color: Color
    ) -> some View {
        let progress = goal > 0 ? min(current / goal, 1.0) : 0.0

        return HStack(spacing: 6) {
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

            Text("\(Int(current)) / \(Int(goal))g")
                .font(.system(size: 10, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(width: 72, alignment: .trailing)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
    }

    // MARK: - Today Section

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 7) {
            exerciseRow
            weightRow
            waterRow
        }
    }

    private var exerciseRow: some View {
        HStack(spacing: 6) {
            Text("\u{1F3C3}") // 🏃
                .font(.system(size: 13))

            Text("\(entry.exerciseSessions)세션 · \(entry.exerciseDuration)분 · \(entry.exerciseCalories)kcal")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
    }

    private var weightRow: some View {
        HStack(spacing: 6) {
            Text("\u{2696}\u{FE0F}") // ⚖️
                .font(.system(size: 13))

            if let current = entry.currentWeight {
                if let target = entry.targetWeight {
                    Text(String(format: "%.1fkg (목표 %.1fkg)", current, target))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                } else {
                    Text(String(format: "%.1fkg", current))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
            } else {
                Text("체중 미기록")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var waterRow: some View {
        HStack(spacing: 6) {
            Text("\u{1F4A7}") // 💧
                .font(.system(size: 13))

            Text("\(entry.waterIntakeCups)/\(entry.waterGoalCups)잔")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
    }

    // MARK: - Streak Section

    private var streakSection: some View {
        HStack {
            Spacer()

            HStack(spacing: 4) {
                Text("\u{1F525}") // 🔥
                    .font(.system(size: 12))

                Text("\(entry.streakDays)일 연속 기록중!")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
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
}

// MARK: - Preview

#Preview("DailyCalorieLarge — 정상", as: .systemLarge) {
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
        streakDays: 7,
        isPlaceholder: false,
        exerciseSessions: 2,
        exerciseDuration: 45,
        weeklyExerciseDays: 4,
        weeklyExerciseGoal: 5,
        currentWeight: 72.5,
        targetWeight: 70.0,
        weightChange7d: -0.3,
        waterIntakeCups: 6,
        waterGoalCups: 8,
        waterIntakeML: 1500
    )
}

#Preview("DailyCalorieLarge — 플레이스홀더", as: .systemLarge) {
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
