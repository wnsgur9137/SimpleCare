//
//  MealFeature.swift
//  MealPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import ComposableArchitecture
import MealDomain
import WidgetKit

// swiftlint:disable file_length

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
        public var healthTip: String?
        public var favorites: [FavoriteFood] = []
        public var showFavorites: Bool = false
        public var recentMeals: [MealRecord] = []
        public var showRecentMeals: Bool = false
        public var showManualInput: Bool = false
        public var editingFavorite: FavoriteFood?
        public var showEditFavorite: Bool = false
        // Water intake
        public var waterIntakes: [WaterIntake] = []
        public var waterGoalMl: Int = 2000

        public var dailyWaterMl: Int {
            waterIntakes.reduce(0) { $0 + $1.amountMl }
        }

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
            estimatedFoods.reduce(0) { $0 + $1.adjustedCalories }
        }

        public var totalProtein: Double {
            estimatedFoods.reduce(0) { $0 + $1.adjustedProtein }
        }

        public var totalCarbs: Double {
            estimatedFoods.reduce(0) { $0 + $1.adjustedCarbs }
        }

        public var totalFat: Double {
            estimatedFoods.reduce(0) { $0 + $1.adjustedFat }
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
        // Quantity
        case adjustFoodQuantity(index: Int, quantity: Double)
        // Manual input
        case toggleManualInput
        case addManualFood(name: String, calories: Int, protein: Double, carbs: Double, fat: Double)
        // Meal copy
        case copyMealsFromDate(Date)
        case copyMealsResponse(Result<[MealRecord], Error>)
        // Favorite edit
        case editFavorite(FavoriteFood)
        case updateFavorite(FavoriteFood)
        case updateFavoriteResponse(Result<Void, Error>)
        case dismissEditFavorite
        // Image picker
        case imageSelected(Data)
        // Water intake
        case loadWaterIntakes
        case loadWaterIntakesResponse(Result<[WaterIntake], Error>)
        case addWaterIntake(Int)
        case addWaterIntakeResponse(Result<Void, Error>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case saveCompleted
        }

        // swiftlint:disable:next cyclomatic_complexity function_body_length
        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.binding(let lVal), .binding(let rVal)):
                return lVal == rVal
            case (.estimateFromText, .estimateFromText),
                 (.estimateFromImage, .estimateFromImage),
                 (.saveMeal, .saveMeal),
                 (.saveMealResponse(.success), .saveMealResponse(.success)),
                 (.saveMealResponse(.failure), .saveMealResponse(.failure)),
                 (.dismissError, .dismissError),
                 (.reset, .reset),
                 (.loadFavorites, .loadFavorites),
                 (.loadFavoritesResponse(.failure), .loadFavoritesResponse(.failure)),
                 (.toggleFavorites, .toggleFavorites),
                 (.saveFavoriteResponse(.success), .saveFavoriteResponse(.success)),
                 (.saveFavoriteResponse(.failure), .saveFavoriteResponse(.failure)),
                 (.deleteFavoriteResponse(.success), .deleteFavoriteResponse(.success)),
                 (.deleteFavoriteResponse(.failure), .deleteFavoriteResponse(.failure)),
                 (.loadRecentMeals, .loadRecentMeals),
                 (.loadRecentMealsResponse(.failure), .loadRecentMealsResponse(.failure)),
                 (.toggleRecentMeals, .toggleRecentMeals),
                 (.toggleManualInput, .toggleManualInput),
                 (.copyMealsResponse(.failure), .copyMealsResponse(.failure)),
                 (.updateFavoriteResponse(.success), .updateFavoriteResponse(.success)),
                 (.updateFavoriteResponse(.failure), .updateFavoriteResponse(.failure)),
                 (.dismissEditFavorite, .dismissEditFavorite),
                 (.loadWaterIntakes, .loadWaterIntakes),
                 (.loadWaterIntakesResponse(.failure), .loadWaterIntakesResponse(.failure)),
                 (.addWaterIntakeResponse(.success), .addWaterIntakeResponse(.success)),
                 (.addWaterIntakeResponse(.failure), .addWaterIntakeResponse(.failure)),
                 (.estimateResponse(.failure), .estimateResponse(.failure)):
                return true
            case (.estimateResponse(.success(let lVal)), .estimateResponse(.success(let rVal))):
                return lVal == rVal
            case (.removeFood(let lVal), .removeFood(let rVal)):
                return lVal == rVal
            case (.loadFavoritesResponse(.success(let lVal)), .loadFavoritesResponse(.success(let rVal))):
                return lVal == rVal
            case (.selectFavorite(let lVal), .selectFavorite(let rVal)):
                return lVal == rVal
            case (.saveFoodAsFavorite(let lVal), .saveFoodAsFavorite(let rVal)):
                return lVal == rVal
            case (.deleteFavorite(let lVal), .deleteFavorite(let rVal)):
                return lVal == rVal
            case (.loadRecentMealsResponse(.success(let lVal)), .loadRecentMealsResponse(.success(let rVal))):
                return lVal == rVal
            case (.selectRecentMeal(let lVal), .selectRecentMeal(let rVal)):
                return lVal == rVal
            case (.adjustFoodQuantity(let li, let lq), .adjustFoodQuantity(let ri, let rq)):
                return li == ri && lq == rq
            case (.addManualFood(let ln, let lc, let lp, let lcb, let lf),
                  .addManualFood(let rn, let rc, let rp, let rcb, let rf)):
                return ln == rn && lc == rc && lp == rp && lcb == rcb && lf == rf
            case (.copyMealsFromDate(let lVal), .copyMealsFromDate(let rVal)):
                return lVal == rVal
            case (.copyMealsResponse(.success(let lVal)), .copyMealsResponse(.success(let rVal))):
                return lVal == rVal
            case (.editFavorite(let lVal), .editFavorite(let rVal)):
                return lVal == rVal
            case (.updateFavorite(let lVal), .updateFavorite(let rVal)):
                return lVal == rVal
            case (.imageSelected(let lVal), .imageSelected(let rVal)):
                return lVal == rVal
            case (.loadWaterIntakesResponse(.success(let lVal)), .loadWaterIntakesResponse(.success(let rVal))):
                return lVal == rVal
            case (.addWaterIntake(let lVal), .addWaterIntake(let rVal)):
                return lVal == rVal
            case (.delegate(let lVal), .delegate(let rVal)):
                return lVal == rVal
            default:
                return false
            }
        }
    }

    // MARK: - Dependencies

    @Dependency(\.mealClient) var mealClient

    // MARK: - Reducer

    public init() {}

    // swiftlint:disable:next function_body_length
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
                    state.healthTip = result.healthTip
                    state.viewState = .idle
                }
                return .none

            case .estimateResponse(.failure(let error)):
                state.viewState = .error(error.userMessage)
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
                WidgetCenter.shared.reloadAllTimelines()
                return .send(.delegate(.saveCompleted))

            case .saveMealResponse(.failure(let error)):
                state.viewState = .error(error.userMessage)
                return .none

            case .dismissError:
                state.viewState = .idle
                return .none

            case .reset:
                state.foodDescription = ""
                state.selectedImageData = nil
                state.estimatedFoods = []
                state.notes = ""
                state.healthTip = nil
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
                state.viewState = .error(error.userMessage)
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
                state.viewState = .error(error.userMessage)
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
                        fiber: item.fiberPerServing,
                        sodium: item.sodiumPerServing,
                        sugar: item.sugarPerServing,
                        quantity: item.quantity,
                        confidence: 1.0
                    )
                }
                state.estimatedFoods.append(contentsOf: foods)
                return .none

            // MARK: - Quantity Adjustment

            case .adjustFoodQuantity(let index, let quantity):
                guard index < state.estimatedFoods.count else { return .none }
                state.estimatedFoods[index].quantity = quantity
                return .none

            // MARK: - Manual Input

            case .toggleManualInput:
                state.showManualInput.toggle()
                return .none

            case .addManualFood(let name, let calories, let protein, let carbs, let fat):
                let food = EstimatedFoodItem(
                    name: name,
                    servingSize: 1,
                    servingUnit: "serving",
                    calories: calories,
                    protein: protein,
                    carbs: carbs,
                    fat: fat,
                    confidence: 1.0
                )
                state.estimatedFoods.append(food)
                state.showManualInput = false
                return .none

            // MARK: - Meal Copy

            case .copyMealsFromDate(let date):
                let userProfileId = state.userProfileId
                return .run { send in
                    do {
                        let meals = try await mealClient.fetchDailyMeals(date, userProfileId)
                        await send(.copyMealsResponse(.success(meals)))
                    } catch {
                        await send(.copyMealsResponse(.failure(error)))
                    }
                }

            case .copyMealsResponse(.success(let meals)):
                let foods = meals.flatMap { meal in
                    meal.foodItems.map { item in
                        EstimatedFoodItem(
                            name: item.name,
                            servingSize: item.servingSize,
                            servingUnit: item.servingUnit,
                            calories: item.caloriesPerServing,
                            protein: item.proteinPerServing,
                            carbs: item.carbsPerServing,
                            fat: item.fatPerServing,
                            fiber: item.fiberPerServing,
                            sodium: item.sodiumPerServing,
                            sugar: item.sugarPerServing,
                            quantity: item.quantity,
                            confidence: 1.0
                        )
                    }
                }
                state.estimatedFoods.append(contentsOf: foods)
                return .none

            case .copyMealsResponse(.failure(let error)):
                state.viewState = .error(error.userMessage)
                return .none

            // MARK: - Favorite Edit

            case .editFavorite(let favorite):
                state.editingFavorite = favorite
                state.showEditFavorite = true
                return .none

            case .updateFavorite(let favorite):
                return .run { send in
                    do {
                        try await mealClient.saveFavorite(favorite)
                        await send(.updateFavoriteResponse(.success(())))
                    } catch {
                        await send(.updateFavoriteResponse(.failure(error)))
                    }
                }

            case .updateFavoriteResponse(.success):
                state.showEditFavorite = false
                state.editingFavorite = nil
                return .send(.loadFavorites)

            case .updateFavoriteResponse(.failure(let error)):
                state.viewState = .error(error.userMessage)
                return .none

            case .dismissEditFavorite:
                state.showEditFavorite = false
                state.editingFavorite = nil
                return .none

            // MARK: - Image Picker

            case .imageSelected(let data):
                state.selectedImageData = data
                return .send(.estimateFromImage)

            // MARK: - Water Intake

            case .loadWaterIntakes:
                let userProfileId = state.userProfileId
                let date = Date()
                return .run { send in
                    do {
                        let intakes = try await mealClient.getDailyWaterIntakes(date, userProfileId)
                        await send(.loadWaterIntakesResponse(.success(intakes)))
                    } catch {
                        await send(.loadWaterIntakesResponse(.failure(error)))
                    }
                }

            case .loadWaterIntakesResponse(.success(let intakes)):
                state.waterIntakes = intakes
                return .none

            case .loadWaterIntakesResponse(.failure):
                return .none

            case .addWaterIntake(let amountMl):
                let intake = WaterIntake(userProfileId: state.userProfileId, amountMl: amountMl)
                return .run { send in
                    do {
                        try await mealClient.recordWaterIntake(intake)
                        await send(.addWaterIntakeResponse(.success(())))
                    } catch {
                        await send(.addWaterIntakeResponse(.failure(error)))
                    }
                }

            case .addWaterIntakeResponse(.success):
                return .send(.loadWaterIntakes)

            case .addWaterIntakeResponse(.failure(let error)):
                state.viewState = .error(error.userMessage)
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

// swiftlint:enable file_length

// MARK: - Dependencies

public struct MealClient {
    public var estimateNutrition: @Sendable (String) async throws -> NutritionEstimation
    public var analyzeMealImage: @Sendable (Data) async throws -> NutritionEstimation
    public var recordMeal: @Sendable (MealRecord) async throws -> Void
    public var updateMeal: @Sendable (MealRecord) async throws -> Void
    public var deleteMeal: @Sendable (MealRecord) async throws -> Void
    public var fetchMeal: @Sendable (UUID) async throws -> MealRecord?
    public var fetchDailyMeals: @Sendable (Date, UUID) async throws -> [MealRecord]
    public var fetchMealHistory: @Sendable (Date, Date, UUID) async throws -> [MealRecord]
    public var getFavorites: @Sendable (UUID) async throws -> [FavoriteFood]
    public var saveFavorite: @Sendable (FavoriteFood) async throws -> Void
    public var deleteFavorite: @Sendable (FavoriteFood) async throws -> Void
    public var incrementFavoriteUsage: @Sendable (FavoriteFood) async throws -> Void
    public var getDailyWaterIntakes: @Sendable (Date, UUID) async throws -> [WaterIntake]
    public var recordWaterIntake: @Sendable (WaterIntake) async throws -> Void

    // swiftlint:disable:next function_parameter_count
    public init(
        estimateNutrition: @escaping @Sendable (String) async throws -> NutritionEstimation,
        analyzeMealImage: @escaping @Sendable (Data) async throws -> NutritionEstimation,
        recordMeal: @escaping @Sendable (MealRecord) async throws -> Void,
        updateMeal: @escaping @Sendable (MealRecord) async throws -> Void,
        deleteMeal: @escaping @Sendable (MealRecord) async throws -> Void,
        fetchMeal: @escaping @Sendable (UUID) async throws -> MealRecord?,
        fetchDailyMeals: @escaping @Sendable (Date, UUID) async throws -> [MealRecord],
        fetchMealHistory: @escaping @Sendable (Date, Date, UUID) async throws -> [MealRecord],
        getFavorites: @escaping @Sendable (UUID) async throws -> [FavoriteFood],
        saveFavorite: @escaping @Sendable (FavoriteFood) async throws -> Void,
        deleteFavorite: @escaping @Sendable (FavoriteFood) async throws -> Void,
        incrementFavoriteUsage: @escaping @Sendable (FavoriteFood) async throws -> Void,
        getDailyWaterIntakes: @escaping @Sendable (Date, UUID) async throws -> [WaterIntake],
        recordWaterIntake: @escaping @Sendable (WaterIntake) async throws -> Void
    ) {
        self.estimateNutrition = estimateNutrition
        self.analyzeMealImage = analyzeMealImage
        self.recordMeal = recordMeal
        self.updateMeal = updateMeal
        self.deleteMeal = deleteMeal
        self.fetchMeal = fetchMeal
        self.fetchDailyMeals = fetchDailyMeals
        self.fetchMealHistory = fetchMealHistory
        self.getFavorites = getFavorites
        self.saveFavorite = saveFavorite
        self.deleteFavorite = deleteFavorite
        self.incrementFavoriteUsage = incrementFavoriteUsage
        self.getDailyWaterIntakes = getDailyWaterIntakes
        self.recordWaterIntake = recordWaterIntake
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
            recordMeal: unimplemented("MealClient.recordMeal"),
            updateMeal: unimplemented("MealClient.updateMeal"),
            deleteMeal: unimplemented("MealClient.deleteMeal"),
            fetchMeal: unimplemented("MealClient.fetchMeal"),
            fetchDailyMeals: unimplemented("MealClient.fetchDailyMeals"),
            fetchMealHistory: unimplemented("MealClient.fetchMealHistory"),
            getFavorites: unimplemented("MealClient.getFavorites"),
            saveFavorite: unimplemented("MealClient.saveFavorite"),
            deleteFavorite: unimplemented("MealClient.deleteFavorite"),
            incrementFavoriteUsage: unimplemented("MealClient.incrementFavoriteUsage"),
            getDailyWaterIntakes: unimplemented("MealClient.getDailyWaterIntakes"),
            recordWaterIntake: unimplemented("MealClient.recordWaterIntake")
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
            updateMeal: { _ in },
            deleteMeal: { _ in },
            fetchMeal: { _ in nil },
            fetchDailyMeals: { _, _ in [] },
            fetchMealHistory: { _, _, _ in [] },
            getFavorites: { _ in [] },
            saveFavorite: { _ in },
            deleteFavorite: { _ in },
            incrementFavoriteUsage: { _ in },
            getDailyWaterIntakes: { _, _ in [] },
            recordWaterIntake: { _ in }
        )
    }
}

extension DependencyValues {
    public var mealClient: MealClient {
        get { self[MealClient.self] }
        set { self[MealClient.self] = newValue }
    }
}
