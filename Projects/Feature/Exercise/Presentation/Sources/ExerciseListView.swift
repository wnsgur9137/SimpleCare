//
//  ExerciseListView.swift
//  ExercisePresentation
//
//  Created by SimpleCare on 3/3/26.
//

import SwiftUI
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
                exerciseListView
            }
        }
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
        .accessibilityLabel("\(exercise.displayName), \(exercise.durationDisplayString), \(exercise.intensity.displayName), \(exercise.caloriesBurned) \("unit.kcal".localized)")
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
