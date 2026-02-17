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
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case saveCompleted
        }

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
                    state.viewState = .error("음식을 추가해주세요")
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

    public init(
        estimateNutrition: @escaping @Sendable (String) async throws -> NutritionEstimation,
        analyzeMealImage: @escaping @Sendable (Data) async throws -> NutritionEstimation,
        recordMeal: @escaping @Sendable (MealRecord) async throws -> Void,
        fetchDailyMeals: @escaping @Sendable (Date, UUID) async throws -> [MealRecord],
        fetchMealHistory: @escaping @Sendable (Date, Date, UUID) async throws -> [MealRecord]
    ) {
        self.estimateNutrition = estimateNutrition
        self.analyzeMealImage = analyzeMealImage
        self.recordMeal = recordMeal
        self.fetchDailyMeals = fetchDailyMeals
        self.fetchMealHistory = fetchMealHistory
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
            fetchMealHistory: { _, _, _ in [] }
        )
    }

    public static var testValue: MealClient {
        MealClient(
            estimateNutrition: { _ in
                NutritionEstimation(
                    foods: [
                        EstimatedFoodItem(
                            name: "테스트 음식",
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
            fetchMealHistory: { _, _, _ in [] }
        )
    }
}

extension DependencyValues {
    public var mealClient: MealClient {
        get { self[MealClient.self] }
        set { self[MealClient.self] = newValue }
    }
}
