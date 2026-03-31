//
//  WeightTrendMediumView.swift
//  SimpleCareWidget
//

import SwiftUI
import WidgetKit
import Charts

// MARK: - WeightTrendMediumView

/// 중형 위젯: 스파크라인 차트 + 체중 상세 정보
struct WeightTrendMediumView: View {

    let entry: WidgetEntry

    // MARK: - Private Helpers

    private var weightChangeColor: Color {
        guard let change = entry.weightChange7d else { return .secondary }
        return change <= 0 ? .green : .red
    }

    private func formatted(_ value: Double?, digits: Int = 1, suffix: String = "") -> String {
        guard let value else { return "--" }
        return String(format: "%.\(digits)f\(suffix)", value)
    }

    private var weightChangeText: String {
        guard let change = entry.weightChange7d else { return "--" }
        let sign = change > 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", change)) kg"
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

    // MARK: - Left Section (SparkLine chart)

    private var leftSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("⚖️ 체중 트렌드")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            sparklineChart
        }
        .padding(.trailing, 8)
    }

    private var sparklineChart: some View {
        Group {
            if entry.recentWeights.isEmpty {
                Text("—")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                Chart(entry.recentWeights, id: \.date) { point in
                    LineMark(
                        x: .value("날짜", point.date),
                        y: .value("체중", point.weight)
                    )
                    .foregroundStyle(Color.widgetSecondary)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("날짜", point.date),
                        y: .value("체중", point.weight)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.widgetSecondary.opacity(0.3), Color.widgetSecondary.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartLegend(.hidden)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - Right Section (Detail rows)

    private var rightSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            detailRow(
                title: "현재",
                value: formatted(entry.currentWeight, suffix: " kg"),
                valueColor: .primary
            )

            detailRow(
                title: "목표",
                value: formatted(entry.targetWeight, suffix: " kg"),
                valueColor: .secondary
            )

            detailRow(
                title: "변화",
                value: weightChangeText + " (7일)",
                valueColor: weightChangeColor
            )

            detailRow(
                title: "BMI",
                value: formatted(entry.bmi, digits: 1),
                valueColor: .secondary
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


// MARK: - Preview

#Preview("WeightTrendMedium — 정상", as: .systemMedium) {
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

#Preview("WeightTrendMedium — 목표 없음", as: .systemMedium) {
    WeightTrendWidget()
} timeline: {
    WidgetEntry(
        date: .now,
        totalCalories: 1_800,
        goalCalories: 2_000,
        remainingCalories: 200,
        calorieProgress: 0.9,
        exerciseCalories: 200,
        totalProtein: 90,
        totalCarbs: 210,
        totalFat: 55,
        proteinGoal: 120,
        carbsGoal: 250,
        fatGoal: 65,
        streakDays: 8,
        isPlaceholder: false,
        currentWeight: 65.2,
        targetWeight: nil,
        weightChange7d: 0.4,
        bmi: 21.5,
        recentWeights: [
            (date: Calendar.current.date(byAdding: .day, value: -4, to: .now)!, weight: 64.9),
            (date: Calendar.current.date(byAdding: .day, value: -3, to: .now)!, weight: 65.0),
            (date: Calendar.current.date(byAdding: .day, value: -2, to: .now)!, weight: 65.1),
            (date: Calendar.current.date(byAdding: .day, value: -1, to: .now)!, weight: 65.3),
            (date: .now, weight: 65.2)
        ]
    )
}

#Preview("WeightTrendMedium — 플레이스홀더", as: .systemMedium) {
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
