//
//  ReportView.swift
//  HomePresentation
//
//  Created by SimpleCare on 2/18/26.
//

import SwiftUI
import ComposableArchitecture
import HomeDomain
import BasePresentation

/// Weekly/Monthly Report View
public struct ReportView: View {
    let store: StoreOf<HomeFeature>

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Report type picker
                    reportTypePicker

                    if store.isLoadingReport {
                        ProgressView()
                            .padding(.top, 40)
                    } else {
                        switch store.reportType {
                        case .weekly:
                            if let report = store.weeklyReport {
                                weeklyReportContent(report)
                            }
                        case .monthly:
                            if let report = store.monthlyReport {
                                monthlyReportContent(report)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("report.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("common.close".localized) {
                        store.send(.dismissReport)
                    }
                }
            }
        }
    }

    // MARK: - Report Type Picker

    private var reportTypePicker: some View {
        Picker("report.type".localized, selection: Binding(
            get: { store.reportType },
            set: { store.send(.selectReportType($0)) }
        )) {
            ForEach(HomeFeature.State.ReportType.allCases, id: \.self) { type in
                Text(type == .weekly ? "report.weekly".localized : "report.monthly".localized).tag(type)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Weekly Report

    private func weeklyReportContent(_ report: WeeklyReport) -> some View {
        VStack(spacing: 16) {
            // Header
            weeklyHeaderSection(report)

            // Daily calories bar chart
            dailyCaloriesChart(report)

            // Exercise summary
            exerciseSummarySection(
                minutes: report.totalExerciseMinutes,
                calories: report.totalExerciseCalories,
                topExercises: report.topExercises
            )

            // Weight change
            if let weightChange = report.weightChange {
                weightChangeSection(weightChange)
            }

            // Goal achievement
            goalAchievementSection(rate: report.goalAchievementRate)
        }
    }

    private func weeklyHeaderSection(_ report: WeeklyReport) -> some View {
        VStack(spacing: 8) {
            Text(weekDateRange(from: report.weekStartDate))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 24) {
                ReportStatBox(
                    title: "report.avgCalories".localized,
                    value: "\(report.avgDailyCalories)",
                    unit: "meal.calories.unit".localized,
                    color: .scPrimary
                )

                ReportStatBox(
                    title: "report.streak".localized,
                    value: "\(report.streakDays)",
                    unit: "report.days".localized,
                    color: .scSuccess
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }

    private func dailyCaloriesChart(_ report: WeeklyReport) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("report.dailyCalories".localized)
                .font(.headline)

            let maxCalories = max(report.dailyCalories.max() ?? 1, report.goalCalories)
            let dayLabels = [
                "home.weekday.mon".localized,
                "home.weekday.tue".localized,
                "home.weekday.wed".localized,
                "home.weekday.thu".localized,
                "home.weekday.fri".localized,
                "home.weekday.sat".localized,
                "home.weekday.sun".localized
            ]

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<min(7, report.dailyCalories.count), id: \.self) { index in
                    VStack(spacing: 4) {
                        Text("\(report.dailyCalories[index])")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(barColor(calories: report.dailyCalories[index], goal: report.goalCalories))
                            .frame(height: max(4, CGFloat(report.dailyCalories[index]) / CGFloat(maxCalories) * 120))

                        Text(dayLabels[index])
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 160)

            // Goal line indicator
            HStack(spacing: 4) {
                Rectangle()
                    .fill(Color.scWarning)
                    .frame(width: 16, height: 2)
                Text("report.goal".localized + ": \(report.goalCalories) " + "meal.calories.unit".localized)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }

    private func exerciseSummarySection(minutes: Int, calories: Int, topExercises: [ExerciseStat]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("report.exerciseSummary".localized)
                .font(.headline)

            HStack(spacing: 24) {
                ReportStatBox(
                    title: "report.totalTime".localized,
                    value: formatDuration(minutes),
                    unit: "",
                    color: .scExercise
                )

                ReportStatBox(
                    title: "report.exerciseCalories".localized,
                    value: "\(calories)",
                    unit: "meal.calories.unit".localized,
                    color: .scExercise
                )
            }

            if !topExercises.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("report.topExercises".localized)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ForEach(topExercises, id: \.name) { stat in
                        HStack {
                            Text(stat.name)
                                .font(.subheadline)
                            Spacer()
                            Text("\(stat.count)" + "report.times".localized)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }

    private func weightChangeSection(_ change: Double) -> some View {
        HStack {
            Image(systemName: change < 0 ? "arrow.down.right" : change > 0 ? "arrow.up.right" : "arrow.right")
                .foregroundStyle(change < 0 ? .scSuccess : change > 0 ? .scWarning : .secondary)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text("report.weightChange".localized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(String(format: "%+.1f ", change) + "weight.unit".localized)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(change < 0 ? .scSuccess : change > 0 ? .scWarning : .primary)
            }

            Spacer()
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }

    private func goalAchievementSection(rate: Double) -> some View {
        VStack(spacing: 8) {
            Text("report.achievementRate".localized)
                .font(.headline)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)

                Circle()
                    .trim(from: 0, to: min(rate, 1.0))
                    .stroke(
                        achievementColor(rate: rate),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Text("\(Int(rate * 100))%")
                    .font(.title)
                    .fontWeight(.bold)
            }
            .frame(width: 100, height: 100)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("accessibility.report.achievementRate".localized(with: Int(rate * 100)))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }

    // MARK: - Monthly Report

    private func monthlyReportContent(_ report: MonthlyReport) -> some View {
        VStack(spacing: 16) {
            // Header
            monthlyHeaderSection(report)

            // Weekly calorie trend
            weeklyCalorieTrendChart(report)

            // Macro average
            macroAverageSection(report.macroAverage)

            // Exercise summary
            VStack(alignment: .leading, spacing: 12) {
                Text("report.exerciseSummary".localized)
                    .font(.headline)

                ReportStatBox(
                    title: "report.totalExerciseTime".localized,
                    value: formatDuration(report.totalExerciseMinutes),
                    unit: "",
                    color: .scExercise
                )
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.regular, in: .rect(cornerRadius: 12))

            // Weight change
            if let weightChange = report.weightChange {
                weightChangeSection(weightChange)
            }

            // Goal achievement
            goalAchievementSection(rate: report.goalAchievementRate)
        }
    }

    private func monthlyHeaderSection(_ report: MonthlyReport) -> some View {
        VStack(spacing: 8) {
            Text(monthLabel(from: report.monthDate))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 24) {
                ReportStatBox(
                    title: "report.avgCalories".localized,
                    value: "\(report.avgDailyCalories)",
                    unit: "meal.calories.unit".localized,
                    color: .scPrimary
                )

                ReportStatBox(
                    title: "report.recordedDays".localized,
                    value: "\(report.recordedDays)",
                    unit: "report.days".localized,
                    color: .scSuccess
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }

    private func weeklyCalorieTrendChart(_ report: MonthlyReport) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("report.weeklyTrend".localized)
                .font(.headline)

            if report.weeklyCalorieTrend.isEmpty {
                Text("weight.noData".localized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                let maxVal = max(report.weeklyCalorieTrend.max() ?? 1, report.goalCalories)

                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(0..<report.weeklyCalorieTrend.count, id: \.self) { index in
                        VStack(spacing: 4) {
                            Text("\(report.weeklyCalorieTrend[index])")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(barColor(calories: report.weeklyCalorieTrend[index], goal: report.goalCalories))
                                .frame(height: max(8, CGFloat(report.weeklyCalorieTrend[index]) / CGFloat(maxVal) * 100))

                            Text("\(index + 1)" + "report.week".localized)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 140)
            }
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }

    private func macroAverageSection(_ macro: MacroAverage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("report.macroAverage".localized)
                .font(.headline)

            // Horizontal bar proportions
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    if macro.total > 0 {
                        Rectangle()
                            .fill(Color.scProtein)
                            .frame(width: geometry.size.width * macro.proteinRatio)

                        Rectangle()
                            .fill(Color.scCarbs)
                            .frame(width: geometry.size.width * macro.carbsRatio)

                        Rectangle()
                            .fill(Color.scFat)
                            .frame(width: geometry.size.width * macro.fatRatio)
                    }
                }
                .clipShape(Capsule())
            }
            .frame(height: 12)

            HStack(spacing: 16) {
                MacroLabel(name: "meal.protein".localized, value: macro.protein, color: .scProtein)
                MacroLabel(name: "meal.carbs".localized, value: macro.carbs, color: .scCarbs)
                MacroLabel(name: "meal.fat".localized, value: macro.fat, color: .scFat)
            }
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }

    // MARK: - DateFormatters

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }()

    private static let monthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("yyyyMMMM")
        return formatter
    }()

    // MARK: - Helpers

    private func barColor(calories: Int, goal: Int) -> Color {
        guard goal > 0 else { return .gray }
        let ratio = Double(calories) / Double(goal)
        if ratio < 0.8 { return .scWarning }
        if ratio <= 1.1 { return .scSuccess }
        return .scError
    }

    private func achievementColor(rate: Double) -> Color {
        if rate < 0.8 { return .scWarning }
        if rate <= 1.1 { return .scSuccess }
        return .scError
    }

    private func formatDuration(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)" + "exercise.minutes".localized
        }
        let hours = minutes / 60
        let mins = minutes % 60
        if mins == 0 {
            return "\(hours)" + "exercise.hours".localized
        }
        return "\(hours)" + "exercise.hours".localized + " \(mins)" + "exercise.minutes".localized
    }

    private func weekDateRange(from startDate: Date) -> String {
        let start = Self.shortDateFormatter.string(from: startDate)
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: startDate) ?? startDate
        let end = Self.shortDateFormatter.string(from: endDate)
        return "\(start) - \(end)"
    }

    private func monthLabel(from date: Date) -> String {
        Self.monthDateFormatter.string(from: date)
    }
}

// MARK: - Sub-components

private struct ReportStatBox: View {
    let title: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(color)

                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(value) \(unit)")
    }
}

private struct MacroLabel: View {
    let name: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                Text(name)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(String(format: "%.0fg", value))
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
