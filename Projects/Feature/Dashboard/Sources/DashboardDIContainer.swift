//
//  DashboardDIContainer.swift
//  Dashboard
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import BasePresentation
import DashboardDomain
import DashboardData
import DashboardPresentation

/// Dashboard DI Container
public final class DashboardDIContainer: DIContainer, @MainActor DashboardCoordinatorDependency {
    public struct Dependencies {
        public let userProfileId: UUID
        public let goalCalories: Int

        public init(userProfileId: UUID, goalCalories: Int) {
            self.userProfileId = userProfileId
            self.goalCalories = goalCalories
        }
    }

    public let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - Repository

    private func makeDashboardRepository() -> DashboardRepositoryProtocol {
        DashboardRepository()
    }

    // MARK: - Use Cases

    private func makeGetDailySummaryUseCase() -> GetDailySummaryUseCaseProtocol {
        GetDailySummaryUseCase(repository: makeDashboardRepository())
    }

    private func makeGenerateInsightUseCase() -> GenerateDailyInsightUseCaseProtocol {
        GenerateDailyInsightUseCase(repository: makeDashboardRepository())
    }

    // MARK: - ViewModels

    @MainActor
    public func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            getDailySummaryUseCase: makeGetDailySummaryUseCase(),
            generateInsightUseCase: makeGenerateInsightUseCase(),
            userProfileId: dependencies.userProfileId,
            goalCalories: dependencies.goalCalories
        )
    }
}
