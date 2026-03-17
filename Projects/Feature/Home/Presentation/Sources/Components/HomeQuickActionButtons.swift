//
//  HomeQuickActionButtons.swift
//  HomePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import BasePresentation

/// 빠른 기록 버튼 그룹
struct HomeQuickActionButtons: View {
    let onMealTap: () -> Void
    let onExerciseTap: () -> Void
    let onWeightTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            HomeQuickActionButton(
                icon: "fork.knife",
                label: "tab.meal".localized,
                color: .scCalories,
                action: onMealTap
            )

            HomeQuickActionButton(
                icon: "figure.run",
                label: "tab.exercise".localized,
                color: .scExercise,
                action: onExerciseTap
            )

            HomeQuickActionButton(
                icon: "scalemass",
                label: "tab.weight".localized,
                color: .scPrimary,
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
                    .fontWeight(.semibold)
                    .foregroundStyle(color)

                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .glassButton(cornerRadius: 12)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("home.accessibility.quickAction".localized(with: label))
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
