//
//  TodayRecordsSection.swift
//  DashboardPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import DashboardDomain

/// 오늘의 기록 섹션
public struct TodayRecordsSection: View {
    let meals: [MealSummary]
    let exercises: [ExerciseSummary]
    let onAddTap: () -> Void

    public init(
        meals: [MealSummary],
        exercises: [ExerciseSummary],
        onAddTap: @escaping () -> Void
    ) {
        self.meals = meals
        self.exercises = exercises
        self.onAddTap = onAddTap
    }

    private var hasRecords: Bool {
        !meals.isEmpty || !exercises.isEmpty
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("오늘의 기록")
                .font(.headline)

            if hasRecords {
                recordsList
            } else {
                EmptyRecordView(onAddTap: onAddTap)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private var recordsList: some View {
        VStack(spacing: 0) {
            // 식사 기록
            ForEach(meals) { meal in
                MealRecordRow(meal: meal)

                if meal.id != meals.last?.id || !exercises.isEmpty {
                    Divider()
                        .padding(.leading, 36)
                }
            }

            // 운동 기록
            ForEach(exercises) { exercise in
                ExerciseRecordRow(exercise: exercise)

                if exercise.id != exercises.last?.id {
                    Divider()
                        .padding(.leading, 36)
                }
            }
        }
    }
}

/// 식사 기록 행
struct MealRecordRow: View {
    let meal: MealSummary

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: meal.mealType.icon)
                .foregroundStyle(.orange)
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
        .accessibilityLabel("\(meal.mealType.displayName), \(meal.foodNamesText), \(meal.totalCalories)칼로리")
    }
}

/// 운동 기록 행
struct ExerciseRecordRow: View {
    let exercise: ExerciseSummary

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "figure.run")
                .foregroundStyle(.green)
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
                .foregroundStyle(.green)
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(exercise.exerciseName), \(exercise.durationText), \(exercise.caloriesBurned)칼로리 소모")
    }
}

/// 빈 상태 뷰
struct EmptyRecordView: View {
    let onAddTap: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)

            Text("아직 기록이 없어요")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: onAddTap) {
                Text("첫 식사 기록하기")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

#Preview("With Records") {
    TodayRecordsSection(
        meals: [
            MealSummary(
                mealType: .breakfast,
                foodNames: ["토스트", "계란프라이", "우유"],
                totalCalories: 420,
                recordedAt: Date()
            ),
            MealSummary(
                mealType: .lunch,
                foodNames: ["비빔밥"],
                totalCalories: 650,
                recordedAt: Date()
            )
        ],
        exercises: [
            ExerciseSummary(
                exerciseName: "달리기",
                duration: 30,
                caloriesBurned: 200,
                recordedAt: Date()
            )
        ],
        onAddTap: {}
    )
    .padding()
}

#Preview("Empty") {
    TodayRecordsSection(
        meals: [],
        exercises: [],
        onAddTap: {}
    )
    .padding()
}
