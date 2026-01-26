//
//  TabDIContainer.swift
//  Features
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import Foundation

import Home
import Settings
import Dashboard
import Meal
import Weight
import Exercise
import Profile
import BasePresentation
import StorageInfra

public final class TabDIContainer: DIContainer {
    public struct Dependencies {
        public init() {}
    }

    public let dependencies: Dependencies

    // Cached user profile for use across features
    private var cachedUserProfile: UserProfileModel?

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - Profile Access

    @MainActor
    private func fetchUserProfile() async -> UserProfileModel? {
        if let cached = cachedUserProfile {
            return cached
        }

        let storage = UserProfileStorage()
        cachedUserProfile = try? await storage.fetchProfile()
        return cachedUserProfile
    }

    // MARK: - Profile

    public func makeProfileDIContainer() -> ProfileDIContainer {
        ProfileDIContainer()
    }

    // MARK: - Home

    @MainActor
    public func makeHomeDIContainer() -> HomeDIContainer {
        let userProfileId = cachedUserProfile?.id ?? UUID()
        let goalCalories = cachedUserProfile?.recommendedDailyCalories ?? 2000

        return HomeDIContainer(
            dependencies: HomeDIContainer.Dependencies(
                userProfileId: userProfileId,
                goalCalories: goalCalories
            )
        )
    }

    // MARK: - Dashboard

    @MainActor
    public func makeDashboardDIContainer() -> DashboardDIContainer {
        let userProfileId = cachedUserProfile?.id ?? UUID()
        let goalCalories = cachedUserProfile?.recommendedDailyCalories ?? 2000

        return DashboardDIContainer(
            dependencies: DashboardDIContainer.Dependencies(
                userProfileId: userProfileId,
                goalCalories: goalCalories
            )
        )
    }

    // MARK: - Meal

    @MainActor
    public func makeMealDIContainer() -> MealDIContainer {
        let userProfileId = cachedUserProfile?.id ?? UUID()

        return MealDIContainer(
            dependencies: MealDIContainer.Dependencies(
                userProfileId: userProfileId
            )
        )
    }

    // MARK: - Weight

    @MainActor
    public func makeWeightDIContainer() -> WeightDIContainer {
        let userProfileId = cachedUserProfile?.id ?? UUID()
        let currentWeight = cachedUserProfile?.currentWeightKg ?? 70.0
        let targetWeight = cachedUserProfile?.targetWeightKg ?? 65.0

        return WeightDIContainer(
            dependencies: WeightDIContainer.Dependencies(
                userProfileId: userProfileId,
                currentWeight: currentWeight,
                targetWeight: targetWeight
            )
        )
    }

    // MARK: - Exercise

    @MainActor
    public func makeExerciseDIContainer() -> ExerciseDIContainer {
        let userProfileId = cachedUserProfile?.id ?? UUID()
        let userWeightKg = cachedUserProfile?.currentWeightKg ?? 70.0

        return ExerciseDIContainer(
            dependencies: ExerciseDIContainer.Dependencies(
                userProfileId: userProfileId,
                userWeightKg: userWeightKg
            )
        )
    }
}
