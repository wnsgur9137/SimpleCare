//
//  HomeDIContainer.swift
//  Home
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import BasePresentation
import HomeDomain
import HomePresentation

/// Home DI Container
public final class HomeDIContainer: DIContainer, HomeCoordinatorDependency {
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

    // MARK: - HomeCoordinatorDependency

    public var userProfileId: UUID {
        dependencies.userProfileId
    }

    public var goalCalories: Int {
        dependencies.goalCalories
    }

    // MARK: - HomeClient

    public var homeClient: HomeClient {
        // TODO: Connect to actual repositories
        HomeClient(
            getDailySummary: { [weak self] date, userProfileId, goalCalories in
                // Placeholder - will be connected to actual data sources
                HomeDailySummary.empty(goalCalories: goalCalories)
            },
            generateInsight: { summary in
                // Placeholder - will be connected to AI service
                .defaultInsight
            }
        )
    }
}
