//
//  MealDetailFeature.swift
//  MealPresentation
//
//  Created by SimpleCare on 2026-02-24.
//

import Foundation
import ComposableArchitecture
import MealDomain

// MARK: - Equatable Error Wrapper

public struct EquatableError: Error, Equatable {
    public let userMessage: String

    public init(_ error: Error) {
        self.userMessage = error.userMessage
    }

    public static func == (lhs: EquatableError, rhs: EquatableError) -> Bool {
        lhs.userMessage == rhs.userMessage
    }
}

@Reducer
public struct MealDetailFeature {
    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var meal: MealRecord
        public var viewState: ViewState = .idle
        public var isEditing: Bool = false
        public var showDeleteConfirmation: Bool = false

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

        public init(meal: MealRecord) {
            self.meal = meal
        }
    }

    // MARK: - Action

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case refreshMeal
        case refreshMealResponse(Result<MealRecord?, EquatableError>)
        case editButtonTapped
        case cancelEdit
        case saveChanges
        case saveChangesResponse(Result<Bool, EquatableError>)
        case deleteButtonTapped
        case confirmDelete
        case cancelDelete
        case deleteResponse(Result<Bool, EquatableError>)
        case dismissError
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case mealUpdated(MealRecord)
            case mealDeleted(UUID)
        }
    }

    // MARK: - Dependencies

    @Dependency(\.mealClient) var mealClient

    // MARK: - Reducer

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .onAppear:
                return .send(.refreshMeal)

            case .refreshMeal:
                state.viewState = .loading
                let mealId = state.meal.id
                return .run { send in
                    do {
                        let meal = try await mealClient.fetchMeal(mealId)
                        await send(.refreshMealResponse(.success(meal)))
                    } catch {
                        await send(.refreshMealResponse(.failure(EquatableError(error))))
                    }
                }

            case .refreshMealResponse(.success(let meal)):
                if let meal {
                    state.meal = meal
                }
                state.viewState = .idle
                return .none

            case .refreshMealResponse(.failure(let error)):
                state.viewState = .error(error.userMessage)
                return .none

            case .editButtonTapped:
                state.isEditing = true
                return .none

            case .cancelEdit:
                state.isEditing = false
                return .send(.refreshMeal)

            case .saveChanges:
                state.viewState = .loading
                let meal = state.meal
                return .run { send in
                    do {
                        try await mealClient.updateMeal(meal)
                        await send(.saveChangesResponse(.success(true)))
                    } catch {
                        await send(.saveChangesResponse(.failure(EquatableError(error))))
                    }
                }

            case .saveChangesResponse(.success):
                state.viewState = .success
                state.isEditing = false
                return .send(.delegate(.mealUpdated(state.meal)))

            case .saveChangesResponse(.failure(let error)):
                state.viewState = .error(error.userMessage)
                return .none

            case .deleteButtonTapped:
                state.showDeleteConfirmation = true
                return .none

            case .confirmDelete:
                state.showDeleteConfirmation = false
                state.viewState = .loading
                let meal = state.meal
                return .run { send in
                    do {
                        try await mealClient.deleteMeal(meal)
                        await send(.deleteResponse(.success(true)))
                    } catch {
                        await send(.deleteResponse(.failure(EquatableError(error))))
                    }
                }

            case .cancelDelete:
                state.showDeleteConfirmation = false
                return .none

            case .deleteResponse(.success):
                state.viewState = .deleted
                return .send(.delegate(.mealDeleted(state.meal.id)))

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
