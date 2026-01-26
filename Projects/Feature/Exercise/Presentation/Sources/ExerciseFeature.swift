//
//  ExerciseFeature.swift
//  ExercisePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import ComposableArchitecture
import ExerciseDomain

@Reducer
public struct ExerciseFeature {
    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var isLoading: Bool = false
        public var exerciseType: ExerciseType = .walking
        public var intensity: ExerciseIntensity = .moderate
        public var durationMinutes: Int = 30
        public var estimatedCalories: Int = 0
        public var notes: String = ""
        public var error: String?

        public var userProfileId: UUID
        public var userWeightKg: Double

        public init(userProfileId: UUID, userWeightKg: Double) {
            self.userProfileId = userProfileId
            self.userWeightKg = userWeightKg
            updateCalorieEstimate()
        }

        mutating func updateCalorieEstimate() {
            estimatedCalories = ExerciseRecord.calculateCalories(
                exerciseType: exerciseType,
                intensity: intensity,
                durationMinutes: durationMinutes,
                weightKg: userWeightKg
            )
        }
    }

    // MARK: - Action

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case saveExercise
        case saveExerciseResponse(Result<Void, Error>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case saveCompleted
        }

        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.binding(let l), .binding(let r)):
                return l == r
            case (.onAppear, .onAppear):
                return true
            case (.saveExercise, .saveExercise):
                return true
            case (.saveExerciseResponse(.success), .saveExerciseResponse(.success)):
                return true
            case (.saveExerciseResponse(.failure), .saveExerciseResponse(.failure)):
                return true
            case (.delegate(let l), .delegate(let r)):
                return l == r
            default:
                return false
            }
        }
    }

    // MARK: - Dependencies

    @Dependency(\.exerciseClient) var exerciseClient

    // MARK: - Reducer

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.exerciseType) { _, _ in
                Reduce { state, _ in
                    state.updateCalorieEstimate()
                    return .none
                }
            }
            .onChange(of: \.intensity) { _, _ in
                Reduce { state, _ in
                    state.updateCalorieEstimate()
                    return .none
                }
            }
            .onChange(of: \.durationMinutes) { _, _ in
                Reduce { state, _ in
                    state.updateCalorieEstimate()
                    return .none
                }
            }

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .onAppear:
                return .none

            case .saveExercise:
                state.isLoading = true
                state.error = nil

                let record = ExerciseRecord(
                    userProfileId: state.userProfileId,
                    exerciseType: state.exerciseType,
                    intensity: state.intensity,
                    durationMinutes: state.durationMinutes,
                    caloriesBurned: state.estimatedCalories,
                    userWeightKg: state.userWeightKg,
                    notes: state.notes.isEmpty ? nil : state.notes
                )

                return .run { send in
                    do {
                        try await exerciseClient.recordExercise(record)
                        await send(.saveExerciseResponse(.success(())))
                    } catch {
                        await send(.saveExerciseResponse(.failure(error)))
                    }
                }

            case .saveExerciseResponse(.success):
                state.isLoading = false
                return .send(.delegate(.saveCompleted))

            case .saveExerciseResponse(.failure(let error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - Dependencies

public struct ExerciseClient {
    public var recordExercise: @Sendable (ExerciseRecord) async throws -> Void

    public init(recordExercise: @escaping @Sendable (ExerciseRecord) async throws -> Void) {
        self.recordExercise = recordExercise
    }
}

extension ExerciseClient: DependencyKey {
    public static var liveValue: ExerciseClient {
        ExerciseClient(recordExercise: { _ in })
    }

    public static var testValue: ExerciseClient {
        ExerciseClient(recordExercise: { _ in })
    }
}

extension DependencyValues {
    public var exerciseClient: ExerciseClient {
        get { self[ExerciseClient.self] }
        set { self[ExerciseClient.self] = newValue }
    }
}
