//
//  ExerciseRecordView.swift
//  ExercisePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import ExerciseDomain
import BasePresentation

public struct ExerciseRecordView: View {
    @Bindable var store: StoreOf<ExerciseFeature>
    @Environment(\.dismiss) private var dismiss

    public init(store: StoreOf<ExerciseFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            Form {
                // 알림 활성화 배너
                Section {
                    NotificationEnableBanner(category: .exercise)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())

                // 운동 종류 선택
                Section("exercise.type".localized) {
                    Picker("exercise.category".localized, selection: $store.selectedCategory.sending(\.selectCategory)) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category)
                        }
                    }

                    Picker("exercise.exercise".localized, selection: $store.exerciseType) {
                        ForEach(ExerciseType.allCases.filter { $0.category == store.selectedCategory }, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }

                    if let selected = store.selectedCustomExercise {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.scWarning)
                            Text(selected.name)
                                .fontWeight(.medium)
                            Spacer()
                            Button("exercise.clear".localized) {
                                store.send(.clearCustomSelection)
                            }
                            .font(.caption)
                        }
                    }
                }

                // 커스텀 운동
                if !store.customExercises.isEmpty {
                    Section("exercise.myCustomExercises".localized) {
                        ForEach(store.customExercises) { exercise in
                            HStack {
                                Button {
                                    store.send(.selectCustomExercise(exercise))
                                } label: {
                                    HStack {
                                        Image(systemName: exercise.iconName ?? exercise.category.icon)
                                            .foregroundStyle(.scPrimary)
                                        VStack(alignment: .leading) {
                                            Text(exercise.name)
                                                .foregroundStyle(.primary)
                                            Text("MET \(String(format: "%.1f", exercise.baseMET)) · \(exercise.category.displayName)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)

                                Spacer()

                                if store.selectedCustomExercise?.id == exercise.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.scPrimary)
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.send(.deleteCustomExercise(exercise))
                                } label: {
                                    Label("common.delete".localized, systemImage: "trash")
                                }
                            }
                        }
                    }
                }

                Section {
                    Button {
                        store.send(.showAddCustomExercise)
                    } label: {
                        Label("exercise.addCustom".localized, systemImage: "plus.circle")
                    }
                }

                // 강도 선택
                Section("exercise.intensity".localized) {
                    Picker("exercise.intensity".localized, selection: $store.intensity) {
                        ForEach(ExerciseIntensity.allCases, id: \.self) { intensity in
                            Text(intensity.displayName).tag(intensity)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // 시간 입력
                Section("exercise.duration".localized) {
                    Stepper("\(store.durationMinutes)\("exercise.minutes".localized)", value: $store.durationMinutes, in: 5...300, step: 5)

                    HStack {
                        ForEach([15, 30, 45, 60], id: \.self) { minutes in
                            Button("\(minutes)\("exercise.minutes".localized)") {
                                store.durationMinutes = minutes
                            }
                            .buttonStyle(.bordered)
                            .tint(store.durationMinutes == minutes ? .scPrimary : .gray)
                        }
                    }
                }

                // 예상 소모 칼로리
                Section("exercise.estimatedCalories".localized) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.scExercise)
                        Text("\(store.estimatedCalories)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("common.kcal".localized)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                }

                // 메모
                Section("exercise.notes".localized) {
                    TextField("exercise.notesPlaceholder".localized, text: $store.notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("exercise.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel".localized) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save".localized) {
                        store.send(.saveExercise)
                    }
                    .disabled(store.isLoading)
                }
            }
            .onChange(of: store.state) { _, _ in
                // Check for delegate actions handled externally
            }
            .sheet(isPresented: $store.showAddCustomSheet) {
                addCustomExerciseSheet
            }
        }
    }

    private var addCustomExerciseSheet: some View {
        NavigationStack {
            Form {
                Section("exercise.info".localized) {
                    TextField("exercise.name".localized, text: $store.customExerciseName)

                    Picker("exercise.category".localized, selection: $store.customExerciseCategory) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }

                Section("exercise.metValue".localized) {
                    HStack {
                        Text("MET")
                        Spacer()
                        Text(String(format: "%.1f", store.customExerciseMET))
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $store.customExerciseMET, in: 1.0...15.0, step: 0.5)

                    Text("exercise.metReference".localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("exercise.addCustom".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel".localized) {
                        store.send(.dismissAddCustomExercise)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save".localized) {
                        store.send(.saveCustomExercise)
                    }
                    .disabled(store.customExerciseName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ExerciseRecordView(
        store: Store(
            initialState: ExerciseFeature.State(
                userProfileId: UUID(),
                userWeightKg: 70
            )
        ) {
            ExerciseFeature()
        }
    )
}
