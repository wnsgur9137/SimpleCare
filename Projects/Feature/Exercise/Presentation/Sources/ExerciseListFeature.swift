//
//  ExerciseListFeature.swift
//  ExercisePresentation
//
//  Created by SimpleCare on 3/3/26.
//

import Foundation
import ComposableArchitecture
import ExerciseDomain

@Reducer
public struct ExerciseListFeature {
    // MARK: - Constants

    private enum Constants {
        static let exerciseHistoryFetchDays = 30
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var exercises: [ExerciseRecord] = []
        public var viewState: ViewState = .idle
        public var userProfileId: UUID

        // Navigation state for TCA-compliant navigation
        public var selectedExerciseForDetail: ExerciseRecord?
        public var shouldNavigateToRecord: Bool = false

        public enum ViewState: Equatable {
            case idle
            case loading
            case loaded
            case error(String)

            var isError: Bool {
                if case .error = self { return true }
                return false
            }
        }

        // Grouped exercises by date for UI
        public var groupedExercises: [(date: Date, exercises: [ExerciseRecord])] {
            let calendar = Calendar.current
            let grouped = Dictionary(grouping: exercises) { exercise in
                calendar.startOfDay(for: exercise.date)
            }
            return grouped.sorted { $0.key > $1.key }
                .map { (date: $0.key, exercises: $0.value.sorted { $0.date > $1.date }) }
        }

        public init(userProfileId: UUID) {
            self.userProfileId = userProfileId
        }
    }

    // MARK: - Action

    public enum Action: Equatable {
        case onAppear
        case loadExercises
        case loadExercisesResponse(Result<[ExerciseRecord], Error>)
        case exerciseTapped(ExerciseRecord)
        case deleteExercise(ExerciseRecord)
        case deleteExerciseResponse(Result<UUID, Error>)
        case addExerciseButtonTapped
        case dismissError
        case resetNavigation
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case navigateToDetail(ExerciseRecord)
            case navigateToRecord
        }

        // swiftlint:disable:next cyclomatic_complexity
        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.onAppear, .onAppear):
                return true
            case (.loadExercises, .loadExercises):
                return true
            case (.loadExercisesResponse(.success(let l)), .loadExercisesResponse(.success(let r))):
                return l == r
            case let (.loadExercisesResponse(.failure(l)), .loadExercisesResponse(.failure(r))):
                return l.localizedDescription == r.localizedDescription
            case (.exerciseTapped(let l), .exerciseTapped(let r)):
                return l == r
            case (.deleteExercise(let l), .deleteExercise(let r)):
                return l == r
            case (.deleteExerciseResponse(.success(let l)), .deleteExerciseResponse(.success(let r))):
                return l == r
            case let (.deleteExerciseResponse(.failure(l)), .deleteExerciseResponse(.failure(r))):
                return l.localizedDescription == r.localizedDescription
            case (.addExerciseButtonTapped, .addExerciseButtonTapped):
                return true
            case (.dismissError, .dismissError):
                return true
            case (.resetNavigation, .resetNavigation):
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
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadExercises)

            case .loadExercises:
                state.viewState = .loading

                let userProfileId = state.userProfileId
                let endDate = Date()
                let startDate = Calendar.current.date(
                    byAdding: .day,
                    value: -Constants.exerciseHistoryFetchDays,
                    to: endDate
                ) ?? endDate

                return .run { send in
                    do {
                        let exercises = try await exerciseClient.fetchExerciseHistory(
                            startDate,
                            endDate,
                            userProfileId
                        )
                        await send(.loadExercisesResponse(.success(exercises)))
                    } catch {
                        await send(.loadExercisesResponse(.failure(error)))
                    }
                }

            case .loadExercisesResponse(.success(let exercises)):
                state.exercises = exercises
                state.viewState = .loaded
                return .none

            case .loadExercisesResponse(.failure(let error)):
                state.viewState = .error(error.userMessage)
                return .none

            case .exerciseTapped(let exercise):
                state.selectedExerciseForDetail = exercise
                return .send(.delegate(.navigateToDetail(exercise)))

            case .deleteExercise(let exercise):
                // Security: Verify ownership before deletion
                guard exercise.userProfileId == state.userProfileId else { return .none }

                state.viewState = .loading
                let exerciseId = exercise.id

                return .run { send in
                    do {
                        try await exerciseClient.deleteExercise(exercise)
                        await send(.deleteExerciseResponse(.success(exerciseId)))
                    } catch {
                        await send(.deleteExerciseResponse(.failure(error)))
                    }
                }

            case .deleteExerciseResponse(.success(let deletedExerciseId)):
                // Optimized: Update local state instead of reloading all exercises
                state.exercises.removeAll { $0.id == deletedExerciseId }
                state.viewState = .loaded
                return .none

            case .deleteExerciseResponse(.failure(let error)):
                state.viewState = .error(error.userMessage)
                return .none

            case .addExerciseButtonTapped:
                state.shouldNavigateToRecord = true
                return .send(.delegate(.navigateToRecord))

            case .dismissError:
                state.viewState = .idle
                return .none

            case .resetNavigation:
                state.selectedExerciseForDetail = nil
                state.shouldNavigateToRecord = false
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
