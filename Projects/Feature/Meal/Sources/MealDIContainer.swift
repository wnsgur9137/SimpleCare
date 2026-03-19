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

    private lazy var mealRepository: MealRepositoryProtocol = MealRepository()

    private lazy var aiService: AIServiceProtocol = AIService()

    private lazy var favoriteFoodRepository: FavoriteFoodDomainRepositoryProtocol = FavoriteFoodDataRepository()

    // MARK: - Use Cases

    private lazy var estimateNutritionUseCase: EstimateMealNutritionUseCaseProtocol = EstimateMealNutritionUseCase(aiService: aiService)

    private lazy var analyzeMealImageUseCase: AnalyzeMealImageUseCaseProtocol = AnalyzeMealImageUseCase(aiService: aiService)

    private lazy var recordMealUseCase: RecordMealUseCaseProtocol = RecordMealUseCase(repository: mealRepository)

    private lazy var getDailyMealsUseCase: GetDailyMealsUseCaseProtocol = GetDailyMealsUseCase(repository: mealRepository)

    private lazy var getMealHistoryUseCase: GetMealHistoryUseCaseProtocol = GetMealHistoryUseCase(repository: mealRepository)

    private lazy var updateMealUseCase: UpdateMealUseCaseProtocol = UpdateMealUseCase(repository: mealRepository)

    private lazy var deleteMealUseCase: DeleteMealUseCaseProtocol = DeleteMealUseCase(repository: mealRepository)

    private lazy var fetchMealUseCase: FetchMealUseCaseProtocol = FetchMealUseCase(repository: mealRepository)

    private lazy var getFavoriteFoodsUseCase: GetFavoriteFoodsUseCaseProtocol = GetFavoriteFoodsUseCase(repository: favoriteFoodRepository)

    private lazy var saveFavoriteFoodUseCase: SaveFavoriteFoodUseCaseProtocol = SaveFavoriteFoodUseCase(repository: favoriteFoodRepository)

    private lazy var deleteFavoriteFoodUseCase: DeleteFavoriteFoodUseCaseProtocol = DeleteFavoriteFoodUseCase(repository: favoriteFoodRepository)

    private lazy var incrementFavoriteUsageUseCase: IncrementFavoriteUsageUseCaseProtocol =
        IncrementFavoriteUsageUseCase(repository: favoriteFoodRepository)

    // MARK: - TCA Dependencies

    public lazy var mealClient: MealClient = {
        let estimateUseCase = self.estimateNutritionUseCase
        let analyzeUseCase = self.analyzeMealImageUseCase
        let recordUseCase = self.recordMealUseCase
        let updateUseCase = self.updateMealUseCase
        let deleteUseCase = self.deleteMealUseCase
        let fetchUseCase = self.fetchMealUseCase
        let dailyMealsUseCase = self.getDailyMealsUseCase
        let historyUseCase = self.getMealHistoryUseCase
        let getFavoritesUseCase = self.getFavoriteFoodsUseCase
        let saveFavoriteUseCase = self.saveFavoriteFoodUseCase
        let deleteFavoriteUseCase = self.deleteFavoriteFoodUseCase
        let incrementUsageUseCase = self.incrementFavoriteUsageUseCase

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
    }()
}
