//
//  MealDetailFeature.swift
//  MealPresentation
//
//  Created by SimpleCare on 2026-02-24.
//

import Foundation
import ComposableArchitecture
import MealDomain

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
        case refreshMealResponse(Result<MealRecord?, Error>)
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
            case mealUpdated(MealRecord)
            case mealDeleted(UUID)
        }

        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.binding(let l), .binding(let r)):
                return l == r
            case (.onAppear, .onAppear):
                return true
            case (.refreshMeal, .refreshMeal):
                return true
            case (.refreshMealResponse(.success(let l)), .refreshMealResponse(.success(let r))):
                return l == r
            case (.refreshMealResponse(.failure), .refreshMealResponse(.failure)):
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
                        await send(.refreshMealResponse(.failure(error)))
                    }
                }

            case .refreshMealResponse(.success(let meal)):
                if let meal {
                    state.meal = meal
                }
                state.viewState = .idle
                return .none

            case .refreshMealResponse(.failure(let error)):
                state.viewState = .error(error.localizedDescription)
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
                        await send(.saveChangesResponse(.success(())))
                    } catch {
                        await send(.saveChangesResponse(.failure(error)))
                    }
                }

            case .saveChangesResponse(.success):
                state.viewState = .success
                state.isEditing = false
                return .send(.delegate(.mealUpdated(state.meal)))

            case .saveChangesResponse(.failure(let error)):
                state.viewState = .error(error.localizedDescription)
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
                return .send(.delegate(.mealDeleted(state.meal.id)))

            case .deleteResponse(.failure(let error)):
                state.viewState = .error(error.localizedDescription)
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
