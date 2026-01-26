//
//  WeeklyTrendView.swift
//  DashboardPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import DashboardDomain

/// 주간 트렌드 뷰
public struct WeeklyTrendView: View {
    let weeklyStatus: [CalorieStatus?]  // 7일, nil = 기록 없음
    let selectedDayIndex: Int
    let onDayTap: (Int) -> Void

    private let weekdays = ["월", "화", "수", "목", "금", "토", "일"]

    public init(
        weeklyStatus: [CalorieStatus?],
        selectedDayIndex: Int = -1,
        onDayTap: @escaping (Int) -> Void
    ) {
        self.weeklyStatus = weeklyStatus
        self.selectedDayIndex = selectedDayIndex
        self.onDayTap = onDayTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("이번 주")
                .font(.headline)

            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    dayColumn(index: index)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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

    private func dotColor(for status: CalorieStatus?) -> Color {
        guard let status = status else {
            return .gray.opacity(0.3)
        }
        switch status {
        case .under: return .orange
        case .onTrack: return .green
        case .over: return .red
        }
    }

    private func accessibilityText(for index: Int, status: CalorieStatus?) -> String {
        let day = weekdays[index]
        guard let status = status else {
            return "\(day)요일, 기록 없음"
        }
        return "\(day)요일, \(status.displayName)"
    }
}

#Preview {
    WeeklyTrendView(
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
