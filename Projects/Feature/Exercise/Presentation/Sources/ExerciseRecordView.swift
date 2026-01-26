//
//  ExerciseRecordView.swift
//  ExercisePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ExerciseDomain

public struct ExerciseRecordView: View {
    @StateObject private var viewModel: ExerciseRecordViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: ExerciseRecordViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            Form {
                // 운동 종류 선택
                Section("운동 종류") {
                    Picker("카테고리", selection: .constant(viewModel.exerciseType.category)) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category)
                        }
                    }

                    Picker("운동", selection: $viewModel.exerciseType) {
                        ForEach(ExerciseType.allCases.filter { $0.category == viewModel.exerciseType.category }, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }

                // 강도 선택
                Section("강도") {
                    Picker("강도", selection: $viewModel.intensity) {
                        ForEach(ExerciseIntensity.allCases, id: \.self) { intensity in
                            Text(intensity.displayName).tag(intensity)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // 시간 입력
                Section("운동 시간") {
                    Stepper("\(viewModel.durationMinutes)분", value: $viewModel.durationMinutes, in: 5...300, step: 5)

                    HStack {
                        ForEach([15, 30, 45, 60], id: \.self) { minutes in
                            Button("\(minutes)분") {
                                viewModel.durationMinutes = minutes
                            }
                            .buttonStyle(.bordered)
                            .tint(viewModel.durationMinutes == minutes ? .blue : .gray)
                        }
                    }
                }

                // 예상 소모 칼로리
                Section("예상 소모 칼로리") {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("\(viewModel.estimatedCalories)")
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
                    TextField("운동 메모", text: $viewModel.notes, axis: .vertical)
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
                        Task {
                            await viewModel.saveExercise()
                            dismiss()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }
}
