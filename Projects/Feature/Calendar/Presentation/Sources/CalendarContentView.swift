//
//  CalendarContentView.swift
//  CalendarPresentation
//
//  Created by JunHyeok Lee on 2/21/26.
//

import SwiftUI
import BasePresentation
import HomeDomain
import CalendarDomain

public struct CalendarContentView: View {
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()
    @State private var dailySummary: HomeDailySummary?
    @State private var isLoading: Bool = false

    private let userProfileId: UUID
    private let goalCalories: Int
    private let macroGoals: MacroGoals
    private let homeClient: HomeClient
    private let onNavigateToMealDetail: (UUID) -> Void
    private let onNavigateToExerciseDetail: (UUID) -> Void

    private var calendar: Calendar { Calendar.current }

    public init(
        userProfileId: UUID,
        goalCalories: Int,
        macroGoals: MacroGoals,
        homeClient: HomeClient,
        onNavigateToMealDetail: @escaping (UUID) -> Void,
        onNavigateToExerciseDetail: @escaping (UUID) -> Void
    ) {
        self.userProfileId = userProfileId
        self.goalCalories = goalCalories
        self.macroGoals = macroGoals
        self.homeClient = homeClient
        self.onNavigateToMealDetail = onNavigateToMealDetail
        self.onNavigateToExerciseDetail = onNavigateToExerciseDetail
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                monthNavigationHeader
                weekdayHeader
                calendarGrid
                dailySummarySection
            }
            .padding()
        }
        .navigationTitle("tab.calendar".localized)
        .task(id: selectedDate) {
            await fetchDailySummary()
        }
    }

    // MARK: - Month Navigation

    private var monthNavigationHeader: some View {
        HStack {
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(monthYearString)
                .font(.title3)
                .fontWeight(.bold)

            Spacer()

            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundStyle(canGoToNextMonth ? Color.secondary : Color.clear)
            }
            .disabled(!canGoToNextMonth)
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Weekday Header

    private var weekdayHeader: some View {
        let symbols = calendar.veryShortWeekdaySymbols
        return HStack {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        let days = daysInMonth()
        let columns = Array(repeating: GridItem(.flexible()), count: 7)

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(days, id: \.self) { date in
                if let date {
                    dayCell(for: date)
                } else {
                    Text("")
                        .frame(height: 40)
                }
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let isFuture = date > Date()

        return Button {
            if !isFuture {
                selectedDate = date
            }
        } label: {
            Text("\(calendar.component(.day, from: date))")
                .font(.body)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(isFuture ? Color.secondary.opacity(0.3) : isSelected ? Color.white : Color.primary)
                .frame(width: 36, height: 36)
                .background {
                    if isSelected {
                        Circle().fill(Color.accentColor)
                    } else if isToday {
                        Circle().strokeBorder(Color.accentColor, lineWidth: 1.5)
                    }
                }
        }
        .disabled(isFuture)
    }

    // MARK: - Daily Summary

    private var dailySummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(dailySummaryTitle)
                .font(.headline)

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else if let summary = dailySummary {
                VStack(spacing: 12) {
                    // Summary overview
                    summaryOverview(summary: summary)

                    // Meal records
                    if !summary.meals.isEmpty {
                        mealRecordsSection(meals: summary.meals)
                    }

                    // Exercise records
                    if !summary.exercises.isEmpty {
                        exerciseRecordsSection(exercises: summary.exercises)
                    }

                    // Empty state
                    if summary.meals.isEmpty && summary.exercises.isEmpty {
                        emptyStateView
                    }
                }
            } else {
                emptyStateView
            }
        }
        .padding(.top, 8)
    }

    private func summaryOverview(summary: HomeDailySummary) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                Text("tab.meal".localized)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(summary.meals.count)건 · \(summary.totalCalories)kcal")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Image(systemName: "figure.run")
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                Text("tab.exercise".localized)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(summary.exercises.count)건 · \(summary.exerciseCalories)kcal")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        }
    }

    private func mealRecordsSection(meals: [HomeMealSummary]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("calendar.mealRecords".localized)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                ForEach(meals) { meal in
                    Button {
                        onNavigateToMealDetail(meal.id)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: meal.mealType.icon)
                                .font(.title3)
                                .foregroundStyle(.accent)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(meal.mealType.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)

                                Text(meal.foodNamesText)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Text("\(meal.totalCalories)kcal")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.regularMaterial)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func exerciseRecordsSection(exercises: [HomeExerciseSummary]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("calendar.exerciseRecords".localized)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                ForEach(exercises) { exercise in
                    Button {
                        onNavigateToExerciseDetail(exercise.id)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "figure.run")
                                .font(.title3)
                                .foregroundStyle(.green)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(exercise.exerciseName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)

                                Text(exercise.durationText)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("\(exercise.caloriesBurned)kcal")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.regularMaterial)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("calendar.noRecords".localized)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        }
    }

    // MARK: - Data Fetching

    private func fetchDailySummary() async {
        isLoading = true
        do {
            let summary = try await homeClient.getDailySummary(
                selectedDate,
                userProfileId,
                goalCalories,
                macroGoals
            )
            dailySummary = summary
        } catch {
            dailySummary = nil
        }
        isLoading = false
    }

    // MARK: - Helpers

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: currentMonth)
    }

    private var dailySummaryTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: selectedDate)
    }

    private var canGoToNextMonth: Bool {
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth),
              let firstDayOfNext = calendar.date(from: calendar.dateComponents([.year, .month], from: nextMonth))
        else { return false }
        return firstDayOfNext <= Date()
    }

    private func moveMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func daysInMonth() -> [Date?] {
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let firstDay = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDay)
        else { return [] }

        let weekday = calendar.component(.weekday, from: firstDay)
        let leadingEmptyDays = weekday - calendar.firstWeekday
        let adjustedLeading = leadingEmptyDays < 0 ? leadingEmptyDays + 7 : leadingEmptyDays

        var days: [Date?] = Array(repeating: nil, count: adjustedLeading)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }

        return days
    }
}
