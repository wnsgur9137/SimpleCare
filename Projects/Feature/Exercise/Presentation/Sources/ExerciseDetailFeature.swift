//
//  ExerciseDetailFeature.swift
//  ExercisePresentation
//
//  Created by SimpleCare on 2026-02-24.
//

import Foundation
import ComposableArchitecture
import ExerciseDomain

@Reducer
public struct ExerciseDetailFeature {
    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var exercise: ExerciseRecord
        public var viewState: ViewState = .idle
        public var isEditing: Bool = false
        public var showDeleteConfirmation: Bool = false

        // Editing state
        public var editingCategory: ExerciseCategory
        public var editingExerciseType: ExerciseType
        public var editingIntensity: ExerciseIntensity
        public var editingDurationMinutes: Int
        public var editingNotes: String

        public enum ViewState: Equatable {
            case idle
            case loading
            case success
            case deleted
            case error(String)

            var isError: Bool {
                if case .error = self { return true }
                return false
            }
        }

        public init(exercise: ExerciseRecord) {
            self.exercise = exercise
            self.editingCategory = exercise.exerciseType.category
            self.editingExerciseType = exercise.exerciseType
            self.editingIntensity = exercise.intensity
            self.editingDurationMinutes = exercise.durationMinutes
            self.editingNotes = exercise.notes ?? ""
        }
    }

    // MARK: - Action

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case refreshExercise
        case refreshExerciseResponse(Result<ExerciseRecord?, Error>)
        case editButtonTapped
        case cancelEdit
        case saveChanges
        case saveChangesResponse(Result<Void, Error>)
        case deleteButtonTapped
        case confirmDelete
        case cancelDelete
        case deleteResponse(Result<Void, Error>)
        case dismissError
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case exerciseUpdated(ExerciseRecord)
            case exerciseDeleted(UUID)
        }

        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.binding(let l), .binding(let r)):
                return l == r
            case (.onAppear, .onAppear):
                return true
            case (.refreshExercise, .refreshExercise):
                return true
            case (.refreshExerciseResponse(.success(let l)), .refreshExerciseResponse(.success(let r))):
                return l == r
            case (.refreshExerciseResponse(.failure), .refreshExerciseResponse(.failure)):
                return true
            case (.editButtonTapped, .editButtonTapped):
                return true
            case (.cancelEdit, .cancelEdit):
                return true
            case (.saveChanges, .saveChanges):
                return true
            case (.saveChangesResponse(.success), .saveChangesResponse(.success)):
                return true
            case (.saveChangesResponse(.failure), .saveChangesResponse(.failure)):
                return true
            case (.deleteButtonTapped, .deleteButtonTapped):
                return true
            case (.confirmDelete, .confirmDelete):
                return true
            case (.cancelDelete, .cancelDelete):
                return true
            case (.deleteResponse(.success), .deleteResponse(.success)):
                return true
            case (.deleteResponse(.failure), .deleteResponse(.failure)):
                return true
            case (.dismissError, .dismissError):
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
            .onChange(of: \.editingCategory) { _, newCategory in
                Reduce { state, _ in
                    // 카테고리 변경 시 해당 카테고리의 첫 번째 유형으로 자동 선택
                    if let firstType = ExerciseType.allCases.first(where: { $0.category == newCategory }) {
                        state.editingExerciseType = firstType
                    }
                    return .none
                }
            }

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .onAppear:
                return .send(.refreshExercise)

            case .refreshExercise:
                state.viewState = .loading
                let exerciseId = state.exercise.id
                return .run { send in
                    do {
                        let exercise = try await exerciseClient.fetchExercise(exerciseId)
                        await send(.refreshExerciseResponse(.success(exercise)))
                    } catch {
                        await send(.refreshExerciseResponse(.failure(error)))
                    }
                }

            case .refreshExerciseResponse(.success(let exercise)):
                if let exercise {
                    state.exercise = exercise
                    state.editingCategory = exercise.exerciseType.category
                    state.editingExerciseType = exercise.exerciseType
                    state.editingIntensity = exercise.intensity
                    state.editingDurationMinutes = exercise.durationMinutes
                    state.editingNotes = exercise.notes ?? ""
                }
                state.viewState = .idle
                return .none

            case .refreshExerciseResponse(.failure(let error)):
                state.viewState = .error(error.userMessage)
                return .none

            case .editButtonTapped:
                state.isEditing = true
                state.editingCategory = state.exercise.exerciseType.category
                state.editingExerciseType = state.exercise.exerciseType
                state.editingIntensity = state.exercise.intensity
                state.editingDurationMinutes = state.exercise.durationMinutes
                state.editingNotes = state.exercise.notes ?? ""
                return .none

            case .cancelEdit:
                state.isEditing = false
                state.editingCategory = state.exercise.exerciseType.category
                state.editingExerciseType = state.exercise.exerciseType
                state.editingIntensity = state.exercise.intensity
                state.editingDurationMinutes = state.exercise.durationMinutes
                state.editingNotes = state.exercise.notes ?? ""
                return .none

            case .saveChanges:
                state.viewState = .loading
                var updatedExercise = state.exercise
                updatedExercise.exerciseType = state.editingExerciseType
                updatedExercise.intensity = state.editingIntensity
                updatedExercise.durationMinutes = state.editingDurationMinutes
                updatedExercise.notes = state.editingNotes.isEmpty ? nil : state.editingNotes
                // 유형 변경 시 baseMET가 바뀌므로 칼로리 재계산
                updatedExercise.caloriesBurned = ExerciseRecord.calculateCalories(
                    exerciseType: state.editingExerciseType,
                    intensity: state.editingIntensity,
                    durationMinutes: state.editingDurationMinutes,
                    weightKg: updatedExercise.userWeightKg,
                    customMET: updatedExercise.customMET
                )
                state.exercise = updatedExercise

                return .run { [exercise = updatedExercise] send in
                    do {
                        try await exerciseClient.updateExercise(exercise)
                        await send(.saveChangesResponse(.success(())))
                    } catch {
                        await send(.saveChangesResponse(.failure(error)))
                    }
                }

            case .saveChangesResponse(.success):
                state.viewState = .success
                state.isEditing = false
                return .send(.delegate(.exerciseUpdated(state.exercise)))

            case .saveChangesResponse(.failure(let error)):
                state.viewState = .error(error.userMessage)
                return .none

            case .deleteButtonTapped:
                state.showDeleteConfirmation = true
                return .none

            case .confirmDelete:
                state.showDeleteConfirmation = false
                state.viewState = .loading
                let exercise = state.exercise
                return .run { send in
                    do {
                        try await exerciseClient.deleteExercise(exercise)
                        await send(.deleteResponse(.success(())))
                    } catch {
                        await send(.deleteResponse(.failure(error)))
                    }
                }

            case .cancelDelete:
                state.showDeleteConfirmation = false
                return .none

            case .deleteResponse(.success):
                state.viewState = .deleted
                return .send(.delegate(.exerciseDeleted(state.exercise.id)))

            case .deleteResponse(.failure(let error)):
                state.viewState = .error(error.userMessage)
                return .none

            case .dismissError:
                state.viewState = .idle
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
