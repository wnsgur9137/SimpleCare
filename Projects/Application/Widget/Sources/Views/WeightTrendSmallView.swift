//
//  WeightTrendSmallView.swift
//  SimpleCareWidget
//

import SwiftUI
import WidgetKit
import Charts

// MARK: - WeightTrendSmallView

/// 소형 위젯: 체중 트렌드 스파크라인 + 현재 체중 + 목표 대비
struct WeightTrendSmallView: View {

    let entry: WidgetEntry

    // MARK: - Private Helpers

    private var currentWeightText: String {
        guard let weight = entry.currentWeight else { return "--" }
        return String(format: "%.1f", weight)
    }

    private var goalDeltaText: String? {
        guard let current = entry.currentWeight,
              let target = entry.targetWeight else { return nil }
        let delta = current - target
        if abs(delta) < 0.05 { return "목표 달성!" }
        let sign = delta > 0 ? "-" : "+"
        return "목표까지 \(sign)\(String(format: "%.1f", abs(delta)))kg"
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            titleLabel
            weightLabel
            sparklineChart
            if let deltaText = goalDeltaText {
                goalDeltaLabel(deltaText)
            }
        }
        .padding(12)
        .if(entry.isPlaceholder) { view in
            view.redacted(reason: .placeholder)
        }
    }

    // MARK: - Subviews

    private var titleLabel: some View {
        Text("⚖️ 체중 트렌드")
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(.secondary)
            .lineLimit(1)
    }

    private var weightLabel: some View {
        HStack(alignment: .lastTextBaseline, spacing: 3) {
            Text(currentWeightText)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text("kg")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    private var sparklineChart: some View {
        Group {
            if entry.recentWeights.isEmpty {
                Text("—")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: 36, alignment: .center)
            } else {
                Chart(entry.recentWeights, id: \.date) { point in
                    LineMark(
                        x: .value("날짜", point.date),
                        y: .value("체중", point.weight)
                    )
                    .foregroundStyle(Color.blue)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("날짜", point.date),
                        y: .value("체중", point.weight)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.25), Color.blue.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartLegend(.hidden)
                .frame(maxWidth: .infinity, maxHeight: 36)
            }
        }
    }

    private func goalDeltaLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .medium, design: .rounded))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}


// MARK: - Preview

#Preview("WeightTrendSmall — 정상", as: .systemSmall) {
    WeightTrendWidget()
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
        currentWeight: 72.5,
        targetWeight: 70.0,
        weightChange7d: -0.8,
        bmi: 23.1,
        recentWeights: [
            (date: Calendar.current.date(byAdding: .day, value: -6, to: .now)!, weight: 73.3),
            (date: Calendar.current.date(byAdding: .day, value: -5, to: .now)!, weight: 73.1),
            (date: Calendar.current.date(byAdding: .day, value: -4, to: .now)!, weight: 73.0),
            (date: Calendar.current.date(byAdding: .day, value: -3, to: .now)!, weight: 72.8),
            (date: Calendar.current.date(byAdding: .day, value: -2, to: .now)!, weight: 72.7),
            (date: Calendar.current.date(byAdding: .day, value: -1, to: .now)!, weight: 72.6),
            (date: .now, weight: 72.5)
        ]
    )
}

#Preview("WeightTrendSmall — 목표 없음", as: .systemSmall) {
    WeightTrendWidget()
} timeline: {
    WidgetEntry(
        date: .now,
        totalCalories: 1_200,
        goalCalories: 2_000,
        remainingCalories: 800,
        calorieProgress: 0.6,
        exerciseCalories: 150,
        totalProtein: 60,
        totalCarbs: 140,
        totalFat: 38,
        proteinGoal: 120,
        carbsGoal: 250,
        fatGoal: 65,
        streakDays: 2,
        isPlaceholder: false,
        currentWeight: 68.0,
        targetWeight: nil,
        weightChange7d: 0.3,
        bmi: 22.4,
        recentWeights: [
            (date: Calendar.current.date(byAdding: .day, value: -3, to: .now)!, weight: 67.8),
            (date: Calendar.current.date(byAdding: .day, value: -2, to: .now)!, weight: 67.9),
            (date: Calendar.current.date(byAdding: .day, value: -1, to: .now)!, weight: 68.1),
            (date: .now, weight: 68.0)
        ]
    )
}

#Preview("WeightTrendSmall — 플레이스홀더", as: .systemSmall) {
    WeightTrendWidget()
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
        currentWeight: 72.5,
        targetWeight: 70.0,
        weightChange7d: -0.8,
        bmi: 23.1,
        recentWeights: [
            (date: Calendar.current.date(byAdding: .day, value: -2, to: .now)!, weight: 73.0),
            (date: Calendar.current.date(byAdding: .day, value: -1, to: .now)!, weight: 72.8),
            (date: .now, weight: 72.5)
        ]
    )
}
