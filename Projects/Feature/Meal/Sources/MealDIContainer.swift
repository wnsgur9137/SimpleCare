//
//  MealDIContainer.swift
//  Meal
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import BasePresentation
import MealDomain
import MealData
import MealPresentation

/// Meal DI Container
public final class MealDIContainer: DIContainer, MealCoordinatorDependency {
    public struct Dependencies {
        public let userProfileId: UUID

        public init(userProfileId: UUID) {
            self.userProfileId = userProfileId
        }
    }

    public let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - MealCoordinatorDependency

    public var userProfileId: UUID {
        dependencies.userProfileId
    }

    // MARK: - Repository

    private func makeMealRepository() -> MealRepositoryProtocol {
        MealRepository()
    }

    private func makeAIService() -> AIServiceProtocol {
        AIService()
    }

    private lazy var favoriteFoodRepository: FavoriteFoodDomainRepositoryProtocol = FavoriteFoodDataRepository()

    // MARK: - Use Cases

    private func makeEstimateNutritionUseCase() -> EstimateMealNutritionUseCaseProtocol {
        EstimateMealNutritionUseCase(aiService: makeAIService())
    }

    private func makeAnalyzeMealImageUseCase() -> AnalyzeMealImageUseCaseProtocol {
        AnalyzeMealImageUseCase(aiService: makeAIService())
    }

    private func makeRecordMealUseCase() -> RecordMealUseCaseProtocol {
        RecordMealUseCase(repository: makeMealRepository())
    }

    private func makeGetDailyMealsUseCase() -> GetDailyMealsUseCaseProtocol {
        GetDailyMealsUseCase(repository: makeMealRepository())
    }

    private func makeGetMealHistoryUseCase() -> GetMealHistoryUseCaseProtocol {
        GetMealHistoryUseCase(repository: makeMealRepository())
    }

    private func makeUpdateMealUseCase() -> UpdateMealUseCaseProtocol {
        UpdateMealUseCase(repository: makeMealRepository())
    }

    private func makeDeleteMealUseCase() -> DeleteMealUseCaseProtocol {
        DeleteMealUseCase(repository: makeMealRepository())
    }

    private func makeFetchMealUseCase() -> FetchMealUseCaseProtocol {
        FetchMealUseCase(repository: makeMealRepository())
    }

    private func makeGetFavoriteFoodsUseCase() -> GetFavoriteFoodsUseCaseProtocol {
        GetFavoriteFoodsUseCase(repository: favoriteFoodRepository)
    }

    private func makeSaveFavoriteFoodUseCase() -> SaveFavoriteFoodUseCaseProtocol {
        SaveFavoriteFoodUseCase(repository: favoriteFoodRepository)
    }

    private func makeDeleteFavoriteFoodUseCase() -> DeleteFavoriteFoodUseCaseProtocol {
        DeleteFavoriteFoodUseCase(repository: favoriteFoodRepository)
    }

    private func makeIncrementFavoriteUsageUseCase() -> IncrementFavoriteUsageUseCaseProtocol {
        IncrementFavoriteUsageUseCase(repository: favoriteFoodRepository)
    }

    // MARK: - TCA Dependencies

    public var mealClient: MealClient {
        let estimateUseCase = makeEstimateNutritionUseCase()
        let analyzeUseCase = makeAnalyzeMealImageUseCase()
        let recordUseCase = makeRecordMealUseCase()
        let updateUseCase = makeUpdateMealUseCase()
        let deleteUseCase = makeDeleteMealUseCase()
        let fetchUseCase = makeFetchMealUseCase()
        let dailyMealsUseCase = makeGetDailyMealsUseCase()
        let historyUseCase = makeGetMealHistoryUseCase()
        let getFavoritesUseCase = makeGetFavoriteFoodsUseCase()
        let saveFavoriteUseCase = makeSaveFavoriteFoodUseCase()
        let deleteFavoriteUseCase = makeDeleteFavoriteFoodUseCase()
        let incrementUsageUseCase = makeIncrementFavoriteUsageUseCase()

        return MealClient(
            estimateNutrition: { text in
                try await estimateUseCase.execute(text: text)
            },
            analyzeMealImage: { imageData in
                try await analyzeUseCase.execute(imageData: imageData)
            },
            recordMeal: { meal in
                try await recordUseCase.execute(meal: meal)
            },
            updateMeal: { meal in
                try await updateUseCase.execute(meal: meal)
            },
            deleteMeal: { meal in
                try await deleteUseCase.execute(meal: meal)
            },
            fetchMeal: { id in
                try await fetchUseCase.execute(id: id)
            },
            fetchDailyMeals: { date, userProfileId in
                try await dailyMealsUseCase.execute(date: date, userProfileId: userProfileId)
            },
            fetchMealHistory: { startDate, endDate, userProfileId in
                try await historyUseCase.execute(from: startDate, to: endDate, userProfileId: userProfileId)
            },
            getFavorites: { userProfileId in
                try await getFavoritesUseCase.execute(userProfileId: userProfileId)
            },
            saveFavorite: { food in
                try await saveFavoriteUseCase.execute(food)
            },
            deleteFavorite: { food in
                try await deleteFavoriteUseCase.execute(food)
            },
            incrementFavoriteUsage: { food in
                try await incrementUsageUseCase.execute(food)
            }
        )
    }
}
