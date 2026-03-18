//
//  HomeWeeklyTrendView.swift
//  HomePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import HomeDomain
import BasePresentation

/// 주간 트렌드 뷰
struct HomeWeeklyTrendView: View {
    let weeklyStatus: [HomeCalorieStatus?]
    let selectedDayIndex: Int
    let onDayTap: (Int) -> Void

    private var weekdays: [String] {
        [
            "home.weekday.mon".localized,
            "home.weekday.tue".localized,
            "home.weekday.wed".localized,
            "home.weekday.thu".localized,
            "home.weekday.fri".localized,
            "home.weekday.sat".localized,
            "home.weekday.sun".localized
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("home.thisWeek".localized)
                .font(.headline)

            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    dayColumn(index: index)
                }
            }
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }

    @ViewBuilder
    private func dayColumn(index: Int) -> some View {
        let status = index < weeklyStatus.count ? weeklyStatus[index] : nil
        let isSelected = index == selectedDayIndex

        Button {
            onDayTap(index)
        } label: {
            VStack(spacing: 8) {
                Circle()
                    .fill(dotColor(for: status))
                    .frame(width: 12, height: 12)
                    .overlay {
                        if isSelected {
                            Circle()
                                .stroke(Color.primary, lineWidth: 2)
                                .frame(width: 18, height: 18)
                        }
                    }

                Text(weekdays[index])
                    .font(.caption2)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityText(for: index, status: status))
    }

    private func dotColor(for status: HomeCalorieStatus?) -> Color {
        guard let status = status else {
            return .gray.opacity(0.3)
        }
        switch status {
        case .under: return .scWarning
        case .onTrack: return .scSuccess
        case .over: return .scError
        }
    }

    private func accessibilityText(for index: Int, status: HomeCalorieStatus?) -> String {
        let day = weekdays[index]
        guard let status = status else {
            return "home.accessibility.weekday.noRecord".localized(with: day)
        }
        return "home.accessibility.weekday.status".localized(with: day, status.displayName)
    }
}

#Preview {
    HomeWeeklyTrendView(
        weeklyStatus: [
            .onTrack,
            .onTrack,
            .over,
            .onTrack,
            .under,
            .onTrack,
            nil
        ],
        selectedDayIndex: 6,
        onDayTap: { _ in }
    )
    .padding()
}
