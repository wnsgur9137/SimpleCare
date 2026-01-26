//
//  ExerciseRecordViewModel.swift
//  ExercisePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import Combine
import ExerciseDomain

@MainActor
public final class ExerciseRecordViewModel: ObservableObject {
    @Published public private(set) var isLoading = false
    @Published public var exerciseType: ExerciseType = .walking
    @Published public var intensity: ExerciseIntensity = .moderate
    @Published public var durationMinutes: Int = 30
    @Published public private(set) var estimatedCalories: Int = 0
    @Published public var notes: String = ""
    @Published public private(set) var error: String?

    private let recordExerciseUseCase: RecordExerciseUseCaseProtocol
    private let estimateCaloriesUseCase: EstimateCalorieBurnUseCaseProtocol
    private let userProfileId: UUID
    private let userWeightKg: Double

    public var onSaveComplete: (() -> Void)?
    private var cancellables = Set<AnyCancellable>()

    public init(
        recordExerciseUseCase: RecordExerciseUseCaseProtocol,
        estimateCaloriesUseCase: EstimateCalorieBurnUseCaseProtocol,
        userProfileId: UUID,
        userWeightKg: Double
    ) {
        self.recordExerciseUseCase = recordExerciseUseCase
        self.estimateCaloriesUseCase = estimateCaloriesUseCase
        self.userProfileId = userProfileId
        self.userWeightKg = userWeightKg

        setupBindings()
    }

    private func setupBindings() {
        Publishers.CombineLatest3($exerciseType, $intensity, $durationMinutes)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] type, intensity, duration in
                self?.updateCalorieEstimate(type: type, intensity: intensity, duration: duration)
            }
            .store(in: &cancellables)
    }

    private func updateCalorieEstimate(type: ExerciseType, intensity: ExerciseIntensity, duration: Int) {
        estimatedCalories = estimateCaloriesUseCase.execute(
            exerciseType: type,
            intensity: intensity,
            durationMinutes: duration,
            weightKg: userWeightKg
        )
    }

    public func saveExercise() async {
        isLoading = true
        error = nil

        do {
            let record = ExerciseRecord(
                userProfileId: userProfileId,
                exerciseType: exerciseType,
                intensity: intensity,
                durationMinutes: durationMinutes,
                caloriesBurned: estimatedCalories,
                userWeightKg: userWeightKg,
                notes: notes.isEmpty ? nil : notes
            )
            try await recordExerciseUseCase.execute(exercise: record)
            onSaveComplete?()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
