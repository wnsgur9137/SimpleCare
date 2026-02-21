//
//  CalendarContentView.swift
//  CalendarPresentation
//
//  Created by JunHyeok Lee on 2/21/26.
//

import SwiftUI
import BasePresentation

public struct CalendarContentView: View {
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()

    private var calendar: Calendar { Calendar.current }

    public init() {}

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

            VStack(spacing: 8) {
                summaryRow(icon: "fork.knife", title: "tab.meal".localized, value: "-")
                summaryRow(icon: "figure.run", title: "tab.exercise".localized, value: "-")
                summaryRow(icon: "scalemass", title: "tab.weight".localized, value: "-")
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
            }
        }
        .padding(.top, 8)
    }

    private func summaryRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
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
