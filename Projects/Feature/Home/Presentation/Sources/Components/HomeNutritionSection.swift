//
//  HomeNutritionSection.swift
//  HomePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import HomeDomain
import BasePresentation

/// 영양소 프로그레스 섹션
struct HomeNutritionSection: View {
    let summary: HomeDailySummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("영양소")
                .font(.headline)

            VStack(spacing: 16) {
                HomeNutritionProgressRow(
                    label: "단백질",
                    current: summary.totalProtein,
                    goal: summary.proteinGoal,
                    color: .scProtein
                )

                HomeNutritionProgressRow(
                    label: "탄수화물",
                    current: summary.totalCarbs,
                    goal: summary.carbsGoal,
                    color: .scCarbs
                )

                HomeNutritionProgressRow(
                    label: "지방",
                    current: summary.totalFat,
                    goal: summary.fatGoal,
                    color: .scFat
                )
            }
        }
        .padding()
        .background(Color.scSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

/// 개별 영양소 프로그레스 바
struct HomeNutritionProgressRow: View {
    let label: String
    let current: Double
    let goal: Double
    let color: Color

    var progress: Double {
        guard goal > 0 else { return 0 }
        return min(current / goal, 1.0)
    }

    var isOverGoal: Bool {
        current > goal
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(Int(current))g / \(Int(goal))g")
                    .font(.caption)
                    .foregroundStyle(isOverGoal ? .scError : .secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(isOverGoal ? Color.scError : color)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.easeOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) \(Int(current))그램, 목표 \(Int(goal))그램")
    }
}
