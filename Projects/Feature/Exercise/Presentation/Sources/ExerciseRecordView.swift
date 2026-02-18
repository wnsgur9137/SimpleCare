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
                // 운동 종류 선택
                Section("운동 종류") {
                    Picker("카테고리", selection: .constant(store.exerciseType.category)) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category)
                        }
                    }

                    Picker("운동", selection: $store.exerciseType) {
                        ForEach(ExerciseType.allCases.filter { $0.category == store.exerciseType.category }, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }

                    if let selected = store.selectedCustomExercise {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text(selected.name)
                                .fontWeight(.medium)
                            Spacer()
                            Button("해제") {
                                store.send(.clearCustomSelection)
                            }
                            .font(.caption)
                        }
                    }
                }

                // 커스텀 운동
                if !store.customExercises.isEmpty {
                    Section("내 커스텀 운동") {
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
                                    Label("삭제", systemImage: "trash")
                                }
                            }
                        }
                    }
                }

                Section {
                    Button {
                        store.send(.showAddCustomExercise)
                    } label: {
                        Label("커스텀 운동 추가", systemImage: "plus.circle")
                    }
                }

                // 강도 선택
                Section("강도") {
                    Picker("강도", selection: $store.intensity) {
                        ForEach(ExerciseIntensity.allCases, id: \.self) { intensity in
                            Text(intensity.displayName).tag(intensity)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // 시간 입력
                Section("운동 시간") {
                    Stepper("\(store.durationMinutes)분", value: $store.durationMinutes, in: 5...300, step: 5)

                    HStack {
                        ForEach([15, 30, 45, 60], id: \.self) { minutes in
                            Button("\(minutes)분") {
                                store.durationMinutes = minutes
                            }
                            .buttonStyle(.bordered)
                            .tint(store.durationMinutes == minutes ? .scPrimary : .gray)
                        }
                    }
                }

                // 예상 소모 칼로리
                Section("예상 소모 칼로리") {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.scExercise)
                        Text("\(store.estimatedCalories)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("kcal")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                }

                // 메모
                Section("메모 (선택)") {
                    TextField("운동 메모", text: $store.notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("운동 기록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
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
                Section("운동 정보") {
                    TextField("운동 이름", text: $store.customExerciseName)

                    Picker("카테고리", selection: $store.customExerciseCategory) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }

                Section("MET 값") {
                    HStack {
                        Text("MET")
                        Spacer()
                        Text(String(format: "%.1f", store.customExerciseMET))
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $store.customExerciseMET, in: 1.0...15.0, step: 0.5)

                    Text("참고: 걷기 3.5, 달리기 8.0, 요가 2.5")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("커스텀 운동 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        store.send(.dismissAddCustomExercise)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
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
