//
//  MealListFeature.swift
//  MealPresentation
//
//  Created by SimpleCare on 2/26/26.
//

import Foundation
import ComposableArchitecture
import MealDomain

@Reducer
public struct MealListFeature {
    // MARK: - Constants

    private enum Constants {
        static let mealHistoryFetchDays = 30
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var meals: [MealRecord] = []
        public var viewState: ViewState = .idle
        public var userProfileId: UUID

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

        // Grouped meals by date for UI
        public var groupedMeals: [(date: Date, meals: [MealRecord])] {
            let calendar = Calendar.current
            let grouped = Dictionary(grouping: meals) { meal in
                calendar.startOfDay(for: meal.date)
            }
            return grouped.sorted { $0.key > $1.key }
                .map { (date: $0.key, meals: $0.value.sorted { $0.date > $1.date }) }
        }

        public init(userProfileId: UUID) {
            self.userProfileId = userProfileId
        }
    }

    // MARK: - Action

    public enum Action: Equatable {
        case onAppear
        case loadMeals
        case loadMealsResponse(Result<[MealRecord], Error>)
        case mealTapped(MealRecord)
        case deleteMeal(MealRecord)
        case deleteMealResponse(Result<UUID, Error>)
        case addMealButtonTapped
        case dismissError
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case navigateToDetail(MealRecord)
            case navigateToRecord
        }

        // swiftlint:disable:next cyclomatic_complexity
        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.onAppear, .onAppear):
                return true
            case (.loadMeals, .loadMeals):
                return true
            case (.loadMealsResponse(.success(let l)), .loadMealsResponse(.success(let r))):
                return l == r
            case (.loadMealsResponse(.failure), .loadMealsResponse(.failure)):
                return true
            case (.mealTapped(let l), .mealTapped(let r)):
                return l == r
            case (.deleteMeal(let l), .deleteMeal(let r)):
                return l == r
            case (.deleteMealResponse(.success(let l)), .deleteMealResponse(.success(let r))):
                return l == r
            case (.deleteMealResponse(.failure), .deleteMealResponse(.failure)):
                return true
            case (.addMealButtonTapped, .addMealButtonTapped):
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
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadMeals)

            case .loadMeals:
                state.viewState = .loading

                let userProfileId = state.userProfileId
                let endDate = Date()
                let startDate = Calendar.current.date(
                    byAdding: .day,
                    value: -Constants.mealHistoryFetchDays,
                    to: endDate
                ) ?? endDate

                return .run { send in
                    do {
                        let meals = try await mealClient.fetchMealHistory(startDate, endDate, userProfileId)
                        await send(.loadMealsResponse(.success(meals)))
                    } catch {
                        await send(.loadMealsResponse(.failure(error)))
                    }
                }

            case .loadMealsResponse(.success(let meals)):
                state.meals = meals
                state.viewState = .loaded
                return .none

            case .loadMealsResponse(.failure(let error)):
                state.viewState = .error(error.userMessage)
                return .none

            case .mealTapped(let meal):
                return .send(.delegate(.navigateToDetail(meal)))

            case .deleteMeal(let meal):
                // Security: Verify ownership before deletion
                guard meal.userProfileId == state.userProfileId else { return .none }

                state.viewState = .loading
                let mealId = meal.id

                return .run { send in
                    do {
                        try await mealClient.deleteMeal(meal)
                        await send(.deleteMealResponse(.success(mealId)))
                    } catch {
                        await send(.deleteMealResponse(.failure(error)))
                    }
                }

            case .deleteMealResponse(.success(let deletedMealId)):
                // Optimized: Update local state instead of reloading all meals
                state.meals.removeAll { $0.id == deletedMealId }
                state.viewState = .loaded
                return .none

            case .deleteMealResponse(.failure(let error)):
                state.viewState = .error(error.userMessage)
                return .none

            case .addMealButtonTapped:
                return .send(.delegate(.navigateToRecord))

            case .dismissError:
                state.viewState = .idle
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
