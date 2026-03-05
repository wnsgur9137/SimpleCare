//
//  TabDIContainer.swift
//  Features
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import Foundation

import Home
import HomeDomain
import Settings
import Meal
import Weight
import Exercise
import Profile
import Calendar
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

    /// 프로필이 로드되었는지 확인하고, 아직이면 fetch
    @MainActor
    public func ensureProfileLoaded() async {
        guard cachedUserProfile == nil else { return }
        let storage = UserProfileStorage()
        cachedUserProfile = try? await storage.fetchProfile()
    }

    /// 현재 사용자 프로필 ID
    @MainActor
    public var userProfileId: UUID? {
        cachedUserProfile?.id
    }

    // MARK: - Helpers

    /// 프로필 기반 MacroGoals 계산
    private func makeMacroGoals(for profile: UserProfileModel?) -> MacroGoals {
        guard let profile = profile else {
            return .default
        }
        let effectiveCalories = Double(profile.recommendedDailyCalories)
        return MacroGoals(
            proteinGoal: Double(profile.dailyProteinGoal ?? Int(profile.currentWeightKg * 1.6)),
            carbsGoal: Double(profile.dailyCarbsGoal ?? Int(effectiveCalories * 0.5 / 4.0)),
            fatGoal: Double(profile.dailyFatGoal ?? Int(effectiveCalories * 0.25 / 9.0))
        )
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
        let macroGoals = makeMacroGoals(for: cachedUserProfile)

        return HomeDIContainer(
            dependencies: HomeDIContainer.Dependencies(
                userProfileId: userProfileId,
                goalCalories: goalCalories,
                macroGoals: macroGoals
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
        let heightCm = cachedUserProfile?.heightCm ?? 170.0

        return WeightDIContainer(
            dependencies: WeightDIContainer.Dependencies(
                userProfileId: userProfileId,
                currentWeight: currentWeight,
                targetWeight: targetWeight,
                heightCm: heightCm
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

    // MARK: - Calendar

    @MainActor
    public func makeCalendarDIContainer() -> CalendarDIContainer {
        let userProfileId = cachedUserProfile?.id ?? UUID()
        let goalCalories = cachedUserProfile?.recommendedDailyCalories ?? 2000
        let macroGoals = makeMacroGoals(for: cachedUserProfile)

        return CalendarDIContainer(
            dependencies: CalendarDIContainer.Dependencies(
                userProfileId: userProfileId,
                goalCalories: goalCalories,
                macroGoals: macroGoals
            )
        )
    }
}
