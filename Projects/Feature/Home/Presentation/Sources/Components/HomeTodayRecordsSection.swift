//
//  HomeTodayRecordsSection.swift
//  HomePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import HomeDomain
import BasePresentation

/// 오늘의 기록 섹션
struct HomeTodayRecordsSection: View {
    let meals: [HomeMealSummary]
    let exercises: [HomeExerciseSummary]
    let onAddTap: () -> Void
    var onMealTap: ((UUID) -> Void)?
    var onExerciseTap: ((UUID) -> Void)?

    private var hasRecords: Bool {
        !meals.isEmpty || !exercises.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("home.todayRecords".localized)
                .font(.headline)

            if hasRecords {
                recordsList
            } else {
                HomeEmptyRecordView(onAddTap: onAddTap)
            }
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }

    @ViewBuilder
    private var recordsList: some View {
        VStack(spacing: 0) {
            ForEach(meals) { meal in
                Button {
                    onMealTap?(meal.id)
                } label: {
                    HomeMealRecordRow(meal: meal)
                }
                .buttonStyle(.plain)

                if meal.id != meals.last?.id || !exercises.isEmpty {
                    Divider()
                        .padding(.leading, 36)
                }
            }

            ForEach(exercises) { exercise in
                Button {
                    onExerciseTap?(exercise.id)
                } label: {
                    HomeExerciseRecordRow(exercise: exercise)
                }
                .buttonStyle(.plain)

                if exercise.id != exercises.last?.id {
                    Divider()
                        .padding(.leading, 36)
                }
            }
        }
    }
}

/// 식사 기록 행
struct HomeMealRecordRow: View {
    let meal: HomeMealSummary

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: meal.mealType.icon)
                .foregroundStyle(.scCalories)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(meal.mealType.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(meal.foodNamesText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text("\(meal.totalCalories) kcal")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("home.accessibility.meal".localized(with: meal.mealType.displayName, meal.foodNamesText, meal.totalCalories))
    }
}

/// 운동 기록 행
struct HomeExerciseRecordRow: View {
    let exercise: HomeExerciseSummary

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "figure.run")
                .foregroundStyle(.scExercise)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.exerciseName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(exercise.durationText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("-\(exercise.caloriesBurned) kcal")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.scExercise)
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("home.accessibility.exercise".localized(with: exercise.exerciseName, exercise.durationText, exercise.caloriesBurned))
    }
}

/// 빈 상태 뷰
struct HomeEmptyRecordView: View {
    let onAddTap: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)

            Text("home.noRecords".localized)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: onAddTap) {
                Text("home.firstMealRecord".localized)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .glassCapsule(tint: .scPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}
