//
//  ExerciseListView.swift
//  ExercisePresentation
//
//  Created by SimpleCare on 3/3/26.
//

import SwiftUI
import Charts
import ComposableArchitecture
import ExerciseDomain
import BasePresentation

public struct ExerciseListView: View {
    @Bindable var store: StoreOf<ExerciseListFeature>

    public init(store: StoreOf<ExerciseListFeature>) {
        self.store = store
    }

    public var body: some View {
        content
            .navigationTitle("exercise.title".localized)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        store.send(.addExerciseButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("accessibility.exercise.addButton".localized)
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch store.viewState {
        case .loading:
            ProgressView()
        case .error(let message):
            errorView(message)
        case .idle, .loaded:
            if store.exercises.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 0) {
                    VStack(spacing: 12) {
                        periodPicker
                        weeklyStreakBadge
                        summaryHeader
                        calorieChartSection
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                    exerciseListView
                }
            }
        }
    }

    private var periodPicker: some View {
        Picker("", selection: Binding(
            get: { store.selectedPeriod },
            set: { store.send(.selectPeriod($0)) }
        )) {
            ForEach(ExerciseListFeature.State.TrendPeriod.allCases, id: \.self) { period in
                Text(period.displayName).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }

    private var weeklyStreakBadge: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(.secondary.opacity(0.2), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: min(Double(store.weeklyExerciseDays) / Double(ExerciseListFeature.weeklyExerciseGoal), 1.0))
                    .stroke(.scPrimary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(store.weeklyExerciseDays)")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text("exercise.weekly.progress".localized)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(String(format: "exercise.weekly.goal".localized, store.weeklyExerciseDays, ExerciseListFeature.weeklyExerciseGoal))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background { RoundedRectangle(cornerRadius: 12).fill(.regularMaterial) }
    }

    private var summaryHeader: some View {
        HStack(spacing: 0) {
            summaryItem(
                title: "exercise.summary.sessions".localized,
                value: "\(store.totalSessions)",
                unit: "exercise.summary.sessionsUnit".localized
            )
            Divider().frame(height: 30)
            summaryItem(
                title: "exercise.summary.calories".localized,
                value: "\(store.totalCalories)",
                unit: "unit.kcal".localized
            )
            Divider().frame(height: 30)
            summaryItem(
                title: "exercise.summary.duration".localized,
                value: formatDuration(store.totalMinutes),
                unit: ""
            )
        }
        .padding(.vertical, 12)
        .background { RoundedRectangle(cornerRadius: 12).fill(.regularMaterial) }
    }

    private func summaryItem(title: String, value: String, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .foregroundStyle(.scExercise)
            if !unit.isEmpty {
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    private func formatDuration(_ minutes: Int) -> String {
        Self.durationFormatter.string(from: TimeInterval(minutes * 60)) ?? ""
    }

    private var calorieChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("exercise.chart.title".localized)
                .font(.headline)

            Chart {
                ForEach(store.dailyCalorieData, id: \.date) { data in
                    BarMark(
                        x: .value("common.date".localized, data.date, unit: .day),
                        y: .value("exercise.summary.calories".localized, data.calories)
                    )
                    .foregroundStyle(.scExercise)
                }
            }
            .frame(height: 180)
            .chartYAxis { AxisMarks(position: .leading) }
        }
        .padding()
        .background { RoundedRectangle(cornerRadius: 12).fill(.regularMaterial) }
    }

    private var exerciseListView: some View {
        List {
            ForEach(store.groupedExercises, id: \.date) { group in
                Section {
                    ForEach(group.exercises) { exercise in
                        ExerciseRowView(exercise: exercise)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                store.send(.exerciseTapped(exercise))
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    store.send(.deleteExercise(exercise))
                                } label: {
                                    Label("common.delete".localized, systemImage: "trash")
                                }
                            }
                    }
                } header: {
                    Text(group.date.formatted(date: .abbreviated, time: .omitted))
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("exercise.list.empty".localized, systemImage: "figure.run")
        } description: {
            Text("exercise.list.emptyDescription".localized)
        } actions: {
            Button {
                store.send(.addExerciseButtonTapped)
            } label: {
                Text("exercise.addExercise".localized)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("error.title".localized, systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button {
                store.send(.loadExercises)
            } label: {
                Text("common.retry".localized)
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct ExerciseRowView: View {
    let exercise: ExerciseRecord

    var body: some View {
        HStack(spacing: 12) {
            // Exercise type icon
            Image(systemName: exercise.exerciseType.category.icon)
                .font(.title2)
                .foregroundStyle(categoryColor)
                .frame(width: 40, height: 40)
                .background(categoryColor.opacity(0.15))
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                // Exercise name
                Text(exercise.displayName)
                    .font(.headline)

                // Duration and intensity
                HStack(spacing: 8) {
                    Text(exercise.durationDisplayString)
                    Text("•")
                    Text(exercise.intensity.displayName)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                // Calories burned
                Text("\(exercise.caloriesBurned)")
                    .font(.headline)
                    .foregroundStyle(.scExercise)
                Text("kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            [
                exercise.displayName,
                exercise.durationDisplayString,
                exercise.intensity.displayName,
                "\(exercise.caloriesBurned) \("unit.kcal".localized)"
            ].joined(separator: ", ")
        )
    }

    private var categoryColor: Color {
        switch exercise.exerciseType.category {
        case .cardio: return .scError
        case .strength: return .scSecondary
        case .flexibility: return .scAccent
        case .sports: return .scSuccess
        case .other: return .scTextSecondary
        }
    }
}
