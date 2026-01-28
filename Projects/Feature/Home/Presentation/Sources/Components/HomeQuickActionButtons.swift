//
//  HomeQuickActionButtons.swift
//  HomePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI

/// 빠른 기록 버튼 그룹
struct HomeQuickActionButtons: View {
    let onMealTap: () -> Void
    let onExerciseTap: () -> Void
    let onWeightTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            HomeQuickActionButton(
                icon: "fork.knife",
                label: "식사",
                color: .green,
                action: onMealTap
            )

            HomeQuickActionButton(
                icon: "figure.run",
                label: "운동",
                color: .orange,
                action: onExerciseTap
            )

            HomeQuickActionButton(
                icon: "scalemass",
                label: "체중",
                color: .blue,
                action: onWeightTap
            )
        }
    }
}

/// 개별 빠른 기록 버튼
struct HomeQuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label) 기록하기")
    }
}

#Preview {
    HomeQuickActionButtons(
        onMealTap: {},
        onExerciseTap: {},
        onWeightTap: {}
    )
    .padding()
}
