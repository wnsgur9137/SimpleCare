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
public final class MealDIContainer: DIContainer, @MainActor MealCoordinatorDependency {
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

    // MARK: - Repository

    private func makeMealRepository() -> MealRepositoryProtocol {
        MealRepository()
    }

    private func makeAIService() -> AIServiceProtocol {
        AIService()
    }

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

    // MARK: - ViewModels

    @MainActor
    public func makeMealRecordViewModel() -> MealRecordViewModel {
        MealRecordViewModel(
            estimateNutritionUseCase: makeEstimateNutritionUseCase(),
            analyzeMealImageUseCase: makeAnalyzeMealImageUseCase(),
            recordMealUseCase: makeRecordMealUseCase(),
            userProfileId: dependencies.userProfileId
        )
    }
}
