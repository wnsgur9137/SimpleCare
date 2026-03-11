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
        public var selectedCategory: ExerciseCategory = .cardio
        public var exerciseType: ExerciseType = .walking
        public var intensity: ExerciseIntensity = .moderate
        public var durationMinutes: Int = 30
        public var estimatedCalories: Int = 0
        public var notes: String = ""
        public var error: String?

        public var userProfileId: UUID
        public var userWeightKg: Double

        // Custom exercise
        public var customExercises: [CustomExercise] = []
        public var customExerciseName: String = ""
        public var customExerciseMET: Double = 4.0
        public var customExerciseCategory: ExerciseCategory = .other
        public var showAddCustomSheet: Bool = false
        public var selectedCustomExercise: CustomExercise?

        public init(userProfileId: UUID, userWeightKg: Double) {
            self.userProfileId = userProfileId
            self.userWeightKg = userWeightKg
            updateCalorieEstimate()
        }

        mutating func updateCalorieEstimate() {
            let customMET = selectedCustomExercise?.baseMET
            estimatedCalories = ExerciseRecord.calculateCalories(
                exerciseType: exerciseType,
                intensity: intensity,
                durationMinutes: durationMinutes,
                weightKg: userWeightKg,
                customMET: customMET
            )
        }
    }

    // MARK: - Action

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case selectCategory(ExerciseCategory)
        case saveExercise
        case saveExerciseResponse(Result<Void, Error>)
        // Custom exercises
        case loadCustomExercises
        case loadCustomExercisesResponse(Result<[CustomExercise], Error>)
        case showAddCustomExercise
        case dismissAddCustomExercise
        case saveCustomExercise
        case saveCustomExerciseResponse(Result<Void, Error>)
        case deleteCustomExercise(CustomExercise)
        case deleteCustomExerciseResponse(Result<Void, Error>)
        case selectCustomExercise(CustomExercise)
        case clearCustomSelection
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
            case (.selectCategory(let l), .selectCategory(let r)):
                return l == r
            case (.saveExercise, .saveExercise):
                return true
            case (.saveExerciseResponse(.success), .saveExerciseResponse(.success)):
                return true
            case (.saveExerciseResponse(.failure), .saveExerciseResponse(.failure)):
                return true
            case (.loadCustomExercises, .loadCustomExercises):
                return true
            case (.loadCustomExercisesResponse(.success(let l)), .loadCustomExercisesResponse(.success(let r))):
                return l == r
            case (.loadCustomExercisesResponse(.failure), .loadCustomExercisesResponse(.failure)):
                return true
            case (.showAddCustomExercise, .showAddCustomExercise):
                return true
            case (.dismissAddCustomExercise, .dismissAddCustomExercise):
                return true
            case (.saveCustomExercise, .saveCustomExercise):
                return true
            case (.saveCustomExerciseResponse(.success), .saveCustomExerciseResponse(.success)):
                return true
            case (.saveCustomExerciseResponse(.failure), .saveCustomExerciseResponse(.failure)):
                return true
            case (.deleteCustomExercise(let l), .deleteCustomExercise(let r)):
                return l == r
            case (.deleteCustomExerciseResponse(.success), .deleteCustomExerciseResponse(.success)):
                return true
            case (.deleteCustomExerciseResponse(.failure), .deleteCustomExerciseResponse(.failure)):
                return true
            case (.selectCustomExercise(let l), .selectCustomExercise(let r)):
                return l == r
            case (.clearCustomSelection, .clearCustomSelection):
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
                    state.selectedCustomExercise = nil
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
                return .send(.loadCustomExercises)

            case let .selectCategory(category):
                state.selectedCategory = category
                // 카테고리 변경 시 해당 카테고리의 첫 번째 운동 타입으로 변경
                // Note: exerciseType 변경 시 .onChange(of: \.exerciseType)에서
                // selectedCustomExercise = nil 및 updateCalorieEstimate()가 자동 호출됨
                if let firstType = ExerciseType.allCases.first(where: { $0.category == category }) {
                    state.exerciseType = firstType
                }
                return .none

            case .saveExercise:
                state.isLoading = true
                state.error = nil

                let customName = state.selectedCustomExercise?.name
                let customMET = state.selectedCustomExercise?.baseMET
                let record = ExerciseRecord(
                    userProfileId: state.userProfileId,
                    exerciseType: state.exerciseType,
                    intensity: state.intensity,
                    durationMinutes: state.durationMinutes,
                    caloriesBurned: state.estimatedCalories,
                    userWeightKg: state.userWeightKg,
                    notes: state.notes.isEmpty ? nil : state.notes,
                    customExerciseName: customName,
                    customMET: customMET
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

            // MARK: - Custom Exercises

            case .loadCustomExercises:
                let userProfileId = state.userProfileId
                return .run { send in
                    do {
                        let exercises = try await exerciseClient.getCustomExercises(userProfileId)
                        await send(.loadCustomExercisesResponse(.success(exercises)))
                    } catch {
                        await send(.loadCustomExercisesResponse(.failure(error)))
                    }
                }

            case .loadCustomExercisesResponse(.success(let exercises)):
                state.customExercises = exercises
                return .none

            case .loadCustomExercisesResponse(.failure(let error)):
                state.error = error.localizedDescription
                return .none

            case .showAddCustomExercise:
                state.customExerciseName = ""
                state.customExerciseMET = 4.0
                state.customExerciseCategory = .other
                state.showAddCustomSheet = true
                return .none

            case .dismissAddCustomExercise:
                state.showAddCustomSheet = false
                return .none

            case .saveCustomExercise:
                guard !state.customExerciseName.isEmpty else { return .none }
                state.showAddCustomSheet = false
                let exercise = CustomExercise(
                    userProfileId: state.userProfileId,
                    name: state.customExerciseName,
                    category: state.customExerciseCategory,
                    baseMET: state.customExerciseMET
                )
                return .run { send in
                    do {
                        try await exerciseClient.saveCustomExercise(exercise)
                        await send(.saveCustomExerciseResponse(.success(())))
                    } catch {
                        await send(.saveCustomExerciseResponse(.failure(error)))
                    }
                }

            case .saveCustomExerciseResponse(.success):
                return .send(.loadCustomExercises)

            case .saveCustomExerciseResponse(.failure(let error)):
                state.error = error.localizedDescription
                return .none

            case .deleteCustomExercise(let exercise):
                return .run { send in
                    do {
                        try await exerciseClient.deleteCustomExercise(exercise)
                        await send(.deleteCustomExerciseResponse(.success(())))
                    } catch {
                        await send(.deleteCustomExerciseResponse(.failure(error)))
                    }
                }

            case .deleteCustomExerciseResponse(.success):
                return .send(.loadCustomExercises)

            case .deleteCustomExerciseResponse(.failure(let error)):
                state.error = error.localizedDescription
                return .none

            case .selectCustomExercise(let exercise):
                state.exerciseType = .other
                state.selectedCustomExercise = exercise
                state.updateCalorieEstimate()
                return .none

            case .clearCustomSelection:
                state.selectedCustomExercise = nil
                state.updateCalorieEstimate()
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
    public var updateExercise: @Sendable (ExerciseRecord) async throws -> Void
    public var deleteExercise: @Sendable (ExerciseRecord) async throws -> Void
    public var fetchExercise: @Sendable (UUID) async throws -> ExerciseRecord?
    public var fetchExercises: @Sendable (Date, UUID) async throws -> [ExerciseRecord]
    public var fetchExerciseHistory: @Sendable (Date, Date, UUID) async throws -> [ExerciseRecord]
    public var getCustomExercises: @Sendable (UUID) async throws -> [CustomExercise]
    public var saveCustomExercise: @Sendable (CustomExercise) async throws -> Void
    public var deleteCustomExercise: @Sendable (CustomExercise) async throws -> Void

    public init(
        recordExercise: @escaping @Sendable (ExerciseRecord) async throws -> Void,
        updateExercise: @escaping @Sendable (ExerciseRecord) async throws -> Void,
        deleteExercise: @escaping @Sendable (ExerciseRecord) async throws -> Void,
        fetchExercise: @escaping @Sendable (UUID) async throws -> ExerciseRecord?,
        fetchExercises: @escaping @Sendable (Date, UUID) async throws -> [ExerciseRecord],
        fetchExerciseHistory: @escaping @Sendable (Date, Date, UUID) async throws -> [ExerciseRecord],
        getCustomExercises: @escaping @Sendable (UUID) async throws -> [CustomExercise],
        saveCustomExercise: @escaping @Sendable (CustomExercise) async throws -> Void,
        deleteCustomExercise: @escaping @Sendable (CustomExercise) async throws -> Void
    ) {
        self.recordExercise = recordExercise
        self.updateExercise = updateExercise
        self.deleteExercise = deleteExercise
        self.fetchExercise = fetchExercise
        self.fetchExercises = fetchExercises
        self.fetchExerciseHistory = fetchExerciseHistory
        self.getCustomExercises = getCustomExercises
        self.saveCustomExercise = saveCustomExercise
        self.deleteCustomExercise = deleteCustomExercise
    }
}

extension ExerciseClient: DependencyKey {
    public static var liveValue: ExerciseClient {
        ExerciseClient(
            recordExercise: { _ in },
            updateExercise: { _ in },
            deleteExercise: { _ in },
            fetchExercise: { _ in nil },
            fetchExercises: { _, _ in [] },
            fetchExerciseHistory: { _, _, _ in [] },
            getCustomExercises: { _ in [] },
            saveCustomExercise: { _ in },
            deleteCustomExercise: { _ in }
        )
    }

    public static var testValue: ExerciseClient {
        ExerciseClient(
            recordExercise: { _ in },
            updateExercise: { _ in },
            deleteExercise: { _ in },
            fetchExercise: { _ in nil },
            fetchExercises: { _, _ in [] },
            fetchExerciseHistory: { _, _, _ in [] },
            getCustomExercises: { _ in [] },
            saveCustomExercise: { _ in },
            deleteCustomExercise: { _ in }
        )
    }
}

extension DependencyValues {
    public var exerciseClient: ExerciseClient {
        get { self[ExerciseClient.self] }
        set { self[ExerciseClient.self] = newValue }
    }
}
