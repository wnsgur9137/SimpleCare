//
//  MealFeature.swift
//  MealPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import ComposableArchitecture
import MealDomain

@Reducer
public struct MealFeature {
    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var viewState: ViewState = .idle
        public var mealType: MealType = .lunch
        public var foodDescription: String = ""
        public var selectedImageData: Data?
        public var estimatedFoods: [EstimatedFoodItem] = []
        public var notes: String = ""
        public var userProfileId: UUID
        public var favorites: [FavoriteFood] = []
        public var showFavorites: Bool = false
        public var recentMeals: [MealRecord] = []
        public var showRecentMeals: Bool = false

        public enum ViewState: Equatable {
            case idle
            case loading
            case estimating
            case success
            case error(String)

            var isError: Bool {
                if case .error = self { return true }
                return false
            }
        }

        public var totalCalories: Int {
            estimatedFoods.reduce(0) { $0 + $1.calories }
        }

        public var totalProtein: Double {
            estimatedFoods.reduce(0) { $0 + $1.protein }
        }

        public var totalCarbs: Double {
            estimatedFoods.reduce(0) { $0 + $1.carbs }
        }

        public var totalFat: Double {
            estimatedFoods.reduce(0) { $0 + $1.fat }
        }

        public var canSave: Bool {
            !estimatedFoods.isEmpty && viewState != .loading && viewState != .estimating
        }

        public init(userProfileId: UUID) {
            self.userProfileId = userProfileId
        }
    }

    // MARK: - Action

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case estimateFromText
        case estimateFromImage
        case estimateResponse(Result<NutritionEstimation, Error>)
        case removeFood(Int)
        case saveMeal
        case saveMealResponse(Result<Void, Error>)
        case dismissError
        case reset
        // Favorites
        case loadFavorites
        case loadFavoritesResponse(Result<[FavoriteFood], Error>)
        case toggleFavorites
        case selectFavorite(FavoriteFood)
        case saveFoodAsFavorite(EstimatedFoodItem)
        case saveFavoriteResponse(Result<Void, Error>)
        case deleteFavorite(FavoriteFood)
        case deleteFavoriteResponse(Result<Void, Error>)
        // Recent meals
        case loadRecentMeals
        case loadRecentMealsResponse(Result<[MealRecord], Error>)
        case toggleRecentMeals
        case selectRecentMeal(MealRecord)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case saveCompleted
        }

        // swiftlint:disable:next cyclomatic_complexity
        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.binding(let l), .binding(let r)):
                return l == r
            case (.estimateFromText, .estimateFromText):
                return true
            case (.estimateFromImage, .estimateFromImage):
                return true
            case (.estimateResponse(.success(let l)), .estimateResponse(.success(let r))):
                return l == r
            case (.estimateResponse(.failure), .estimateResponse(.failure)):
                return true
            case (.removeFood(let l), .removeFood(let r)):
                return l == r
            case (.saveMeal, .saveMeal):
                return true
            case (.saveMealResponse(.success), .saveMealResponse(.success)):
                return true
            case (.saveMealResponse(.failure), .saveMealResponse(.failure)):
                return true
            case (.dismissError, .dismissError):
                return true
            case (.reset, .reset):
                return true
            case (.loadFavorites, .loadFavorites):
                return true
            case (.loadFavoritesResponse(.success(let l)), .loadFavoritesResponse(.success(let r))):
                return l == r
            case (.loadFavoritesResponse(.failure), .loadFavoritesResponse(.failure)):
                return true
            case (.toggleFavorites, .toggleFavorites):
                return true
            case (.selectFavorite(let l), .selectFavorite(let r)):
                return l == r
            case (.saveFoodAsFavorite(let l), .saveFoodAsFavorite(let r)):
                return l == r
            case (.saveFavoriteResponse(.success), .saveFavoriteResponse(.success)):
                return true
            case (.saveFavoriteResponse(.failure), .saveFavoriteResponse(.failure)):
                return true
            case (.deleteFavorite(let l), .deleteFavorite(let r)):
                return l == r
            case (.deleteFavoriteResponse(.success), .deleteFavoriteResponse(.success)):
                return true
            case (.deleteFavoriteResponse(.failure), .deleteFavoriteResponse(.failure)):
                return true
            case (.loadRecentMeals, .loadRecentMeals):
                return true
            case (.loadRecentMealsResponse(.success(let l)), .loadRecentMealsResponse(.success(let r))):
                return l == r
            case (.loadRecentMealsResponse(.failure), .loadRecentMealsResponse(.failure)):
                return true
            case (.toggleRecentMeals, .toggleRecentMeals):
                return true
            case (.selectRecentMeal(let l), .selectRecentMeal(let r)):
                return l == r
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

            case .estimateFromText:
                guard !state.foodDescription.isEmpty else { return .none }

                state.viewState = .estimating
                let text = state.foodDescription

                return .run { send in
                    do {
                        let result = try await mealClient.estimateNutrition(text)
                        await send(.estimateResponse(.success(result)))
                    } catch {
                        await send(.estimateResponse(.failure(error)))
                    }
                }

            case .estimateFromImage:
                guard let imageData = state.selectedImageData else { return .none }

                state.viewState = .estimating

                return .run { send in
                    do {
                        let result = try await mealClient.analyzeMealImage(imageData)
                        await send(.estimateResponse(.success(result)))
                    } catch {
                        await send(.estimateResponse(.failure(error)))
                    }
                }

            case .estimateResponse(.success(let result)):
                if let error = result.error {
                    state.viewState = .error(error)
                } else {
                    state.estimatedFoods = result.foods
                    state.viewState = .idle
                }
                return .none

            case .estimateResponse(.failure(let error)):
                state.viewState = .error(error.localizedDescription)
                return .none

            case .removeFood(let index):
                guard index < state.estimatedFoods.count else { return .none }
                state.estimatedFoods.remove(at: index)
                return .none

            case .saveMeal:
                guard !state.estimatedFoods.isEmpty else {
                    state.viewState = .error("meal.addFood".localized)
                    return .none
                }

                state.viewState = .loading

                let foodItems = state.estimatedFoods.map { $0.toFoodItem() }
                let meal = MealRecord(
                    userProfileId: state.userProfileId,
                    mealType: state.mealType,
                    foodItems: foodItems,
                    notes: state.notes.isEmpty ? nil : state.notes
                )

                return .run { send in
                    do {
                        try await mealClient.recordMeal(meal)
                        await send(.saveMealResponse(.success(())))
                    } catch {
                        await send(.saveMealResponse(.failure(error)))
                    }
                }

            case .saveMealResponse(.success):
                state.viewState = .success
                return .send(.delegate(.saveCompleted))

            case .saveMealResponse(.failure(let error)):
                state.viewState = .error(error.localizedDescription)
                return .none

            case .dismissError:
                state.viewState = .idle
                return .none

            case .reset:
                state.foodDescription = ""
                state.selectedImageData = nil
                state.estimatedFoods = []
                state.notes = ""
                state.viewState = .idle
                return .none

            // MARK: - Favorites

            case .loadFavorites:
                let userProfileId = state.userProfileId
                return .run { send in
                    do {
                        let favorites = try await mealClient.getFavorites(userProfileId)
                        await send(.loadFavoritesResponse(.success(favorites)))
                    } catch {
                        await send(.loadFavoritesResponse(.failure(error)))
                    }
                }

            case .loadFavoritesResponse(.success(let favorites)):
                state.favorites = favorites
                return .none

            case .loadFavoritesResponse(.failure):
                state.favorites = []
                return .none

            case .toggleFavorites:
                state.showFavorites.toggle()
                if state.showFavorites && state.favorites.isEmpty {
                    return .send(.loadFavorites)
                }
                return .none

            case .selectFavorite(let favorite):
                let food = favorite.toEstimatedFoodItem()
                state.estimatedFoods.append(food)
                let userProfileId = state.userProfileId
                return .run { _ in
                    try? await mealClient.incrementFavoriteUsage(favorite)
                }

            case .saveFoodAsFavorite(let food):
                let favorite = FavoriteFood.from(food, userProfileId: state.userProfileId)
                return .run { send in
                    do {
                        try await mealClient.saveFavorite(favorite)
                        await send(.saveFavoriteResponse(.success(())))
                    } catch {
                        await send(.saveFavoriteResponse(.failure(error)))
                    }
                }

            case .saveFavoriteResponse(.success):
                return .send(.loadFavorites)

            case .saveFavoriteResponse(.failure(let error)):
                state.viewState = .error(error.localizedDescription)
                return .none

            case .deleteFavorite(let favorite):
                return .run { send in
                    do {
                        try await mealClient.deleteFavorite(favorite)
                        await send(.deleteFavoriteResponse(.success(())))
                    } catch {
                        await send(.deleteFavoriteResponse(.failure(error)))
                    }
                }

            case .deleteFavoriteResponse(.success):
                return .send(.loadFavorites)

            case .deleteFavoriteResponse(.failure(let error)):
                state.viewState = .error(error.localizedDescription)
                return .none

            // MARK: - Recent Meals

            case .loadRecentMeals:
                let userProfileId = state.userProfileId
                let endDate = Date()
                let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate) ?? endDate
                return .run { send in
                    do {
                        let meals = try await mealClient.fetchMealHistory(startDate, endDate, userProfileId)
                        await send(.loadRecentMealsResponse(.success(meals)))
                    } catch {
                        await send(.loadRecentMealsResponse(.failure(error)))
                    }
                }

            case .loadRecentMealsResponse(.success(let meals)):
                state.recentMeals = meals
                return .none

            case .loadRecentMealsResponse(.failure):
                return .none

            case .toggleRecentMeals:
                state.showRecentMeals.toggle()
                if state.showRecentMeals && state.recentMeals.isEmpty {
                    return .send(.loadRecentMeals)
                }
                return .none

            case .selectRecentMeal(let meal):
                let foods = meal.foodItems.map { item in
                    EstimatedFoodItem(
                        name: item.name,
                        servingSize: item.servingSize,
                        servingUnit: item.servingUnit,
                        calories: item.caloriesPerServing,
                        protein: item.proteinPerServing,
                        carbs: item.carbsPerServing,
                        fat: item.fatPerServing,
                        confidence: 1.0
                    )
                }
                state.estimatedFoods.append(contentsOf: foods)
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - Dependencies

public struct MealClient {
    public var estimateNutrition: @Sendable (String) async throws -> NutritionEstimation
    public var analyzeMealImage: @Sendable (Data) async throws -> NutritionEstimation
    public var recordMeal: @Sendable (MealRecord) async throws -> Void
    public var fetchDailyMeals: @Sendable (Date, UUID) async throws -> [MealRecord]
    public var fetchMealHistory: @Sendable (Date, Date, UUID) async throws -> [MealRecord]
    public var getFavorites: @Sendable (UUID) async throws -> [FavoriteFood]
    public var saveFavorite: @Sendable (FavoriteFood) async throws -> Void
    public var deleteFavorite: @Sendable (FavoriteFood) async throws -> Void
    public var incrementFavoriteUsage: @Sendable (FavoriteFood) async throws -> Void

    public init(
        estimateNutrition: @escaping @Sendable (String) async throws -> NutritionEstimation,
        analyzeMealImage: @escaping @Sendable (Data) async throws -> NutritionEstimation,
        recordMeal: @escaping @Sendable (MealRecord) async throws -> Void,
        fetchDailyMeals: @escaping @Sendable (Date, UUID) async throws -> [MealRecord],
        fetchMealHistory: @escaping @Sendable (Date, Date, UUID) async throws -> [MealRecord],
        getFavorites: @escaping @Sendable (UUID) async throws -> [FavoriteFood],
        saveFavorite: @escaping @Sendable (FavoriteFood) async throws -> Void,
        deleteFavorite: @escaping @Sendable (FavoriteFood) async throws -> Void,
        incrementFavoriteUsage: @escaping @Sendable (FavoriteFood) async throws -> Void
    ) {
        self.estimateNutrition = estimateNutrition
        self.analyzeMealImage = analyzeMealImage
        self.recordMeal = recordMeal
        self.fetchDailyMeals = fetchDailyMeals
        self.fetchMealHistory = fetchMealHistory
        self.getFavorites = getFavorites
        self.saveFavorite = saveFavorite
        self.deleteFavorite = deleteFavorite
        self.incrementFavoriteUsage = incrementFavoriteUsage
    }
}

extension MealClient: DependencyKey {
    public static var liveValue: MealClient {
        MealClient(
            estimateNutrition: { _ in
                NutritionEstimation(foods: [], totalCalories: 0)
            },
            analyzeMealImage: { _ in
                NutritionEstimation(foods: [], totalCalories: 0)
            },
            recordMeal: { _ in },
            fetchDailyMeals: { _, _ in [] },
            fetchMealHistory: { _, _, _ in [] },
            getFavorites: { _ in [] },
            saveFavorite: { _ in },
            deleteFavorite: { _ in },
            incrementFavoriteUsage: { _ in }
        )
    }

    public static var testValue: MealClient {
        MealClient(
            estimateNutrition: { _ in
                NutritionEstimation(
                    foods: [
                        EstimatedFoodItem(
                            name: "meal.testFood".localized,
                            servingSize: 100,
                            servingUnit: "g",
                            calories: 300,
                            protein: 20,
                            carbs: 30,
                            fat: 10,
                            confidence: 0.85
                        )
                    ],
                    totalCalories: 300
                )
            },
            analyzeMealImage: { _ in
                NutritionEstimation(foods: [], totalCalories: 0)
            },
            recordMeal: { _ in },
            fetchDailyMeals: { _, _ in [] },
            fetchMealHistory: { _, _, _ in [] },
            getFavorites: { _ in [] },
            saveFavorite: { _ in },
            deleteFavorite: { _ in },
            incrementFavoriteUsage: { _ in }
        )
    }
}

extension DependencyValues {
    public var mealClient: MealClient {
        get { self[MealClient.self] }
        set { self[MealClient.self] = newValue }
    }
}
