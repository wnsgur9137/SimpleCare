//
//  ProfileRepository.swift
//  ProfileData
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import ProfileDomain
import StorageInfra

/// Profile Repository 구현
public final class ProfileRepository: UserProfileRepositoryProtocol, Sendable {
    private let storage: UserProfileStorage

    public init(storage: UserProfileStorage = UserProfileStorage()) {
        self.storage = storage
    }

    public func getProfile() async throws -> UserProfile? {
        guard let model = try await storage.fetchProfile() else {
            return nil
        }
        return model.toEntity()
    }

    public func saveProfile(_ profile: UserProfile) async throws {
        let model = profile.toModel()
        try await storage.saveProfile(model)
    }

    public func updateProfile(_ profile: UserProfile) async throws {
        guard let existingModel = try await storage.fetchProfile() else {
            throw ProfileRepositoryError.profileNotFound
        }
        profile.updateModel(existingModel)
        try await storage.updateProfile(existingModel)
    }

    public func deleteProfile() async throws {
        try await storage.deleteProfile()
    }
}

/// Repository 에러
public enum ProfileRepositoryError: LocalizedError {
    case profileNotFound

    public var errorDescription: String? {
        switch self {
        case .profileNotFound:
            return "error.profileNotFound".localized
        }
    }
}

// MARK: - Mapping Extensions

extension UserProfileModel {
    func toEntity() -> UserProfile {
        UserProfile(
            id: id,
            name: name,
            heightCm: heightCm,
            currentWeightKg: currentWeightKg,
            targetWeightKg: targetWeightKg,
            age: age,
            biologicalSex: biologicalSex.toEntity(),
            activityLevel: activityLevel.toEntity(),
            goalType: goalType.toEntity(),
            dailyCalorieGoal: dailyCalorieGoal,
            dailyProteinGoal: dailyProteinGoal,
            dailyCarbsGoal: dailyCarbsGoal,
            dailyFatGoal: dailyFatGoal,
            breakfastCalorieRatio: breakfastCalorieRatio,
            lunchCalorieRatio: lunchCalorieRatio,
            dinnerCalorieRatio: dinnerCalorieRatio,
            snackCalorieRatio: snackCalorieRatio,
            isOnboardingCompleted: isOnboardingCompleted,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension UserProfile {
    func toModel() -> UserProfileModel {
        UserProfileModel(
            id: id,
            name: name,
            heightCm: heightCm,
            currentWeightKg: currentWeightKg,
            targetWeightKg: targetWeightKg,
            age: age,
            biologicalSex: biologicalSex.toStorageModel(),
            activityLevel: activityLevel.toStorageModel(),
            goalType: goalType.toStorageModel(),
            dailyCalorieGoal: dailyCalorieGoal,
            dailyProteinGoal: dailyProteinGoal,
            dailyCarbsGoal: dailyCarbsGoal,
            dailyFatGoal: dailyFatGoal,
            breakfastCalorieRatio: breakfastCalorieRatio,
            lunchCalorieRatio: lunchCalorieRatio,
            dinnerCalorieRatio: dinnerCalorieRatio,
            snackCalorieRatio: snackCalorieRatio,
            isOnboardingCompleted: isOnboardingCompleted,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    func updateModel(_ model: UserProfileModel) {
        model.name = name
        model.heightCm = heightCm
        model.currentWeightKg = currentWeightKg
        model.targetWeightKg = targetWeightKg
        model.age = age
        model.biologicalSex = biologicalSex.toStorageModel()
        model.activityLevel = activityLevel.toStorageModel()
        model.goalType = goalType.toStorageModel()
        model.dailyCalorieGoal = dailyCalorieGoal
        model.dailyProteinGoal = dailyProteinGoal
        model.dailyCarbsGoal = dailyCarbsGoal
        model.dailyFatGoal = dailyFatGoal
        model.breakfastCalorieRatio = breakfastCalorieRatio
        model.lunchCalorieRatio = lunchCalorieRatio
        model.dinnerCalorieRatio = dinnerCalorieRatio
        model.snackCalorieRatio = snackCalorieRatio
        model.isOnboardingCompleted = isOnboardingCompleted
        model.updatedAt = Date()
    }
}

// MARK: - Enum Mapping

extension StorageInfra.BiologicalSex {
    func toEntity() -> ProfileDomain.BiologicalSex {
        switch self {
        case .male: return .male
        case .female: return .female
        }
    }
}

extension ProfileDomain.BiologicalSex {
    func toStorageModel() -> StorageInfra.BiologicalSex {
        switch self {
        case .male: return .male
        case .female: return .female
        }
    }
}

extension StorageInfra.ActivityLevel {
    func toEntity() -> ProfileDomain.ActivityLevel {
        switch self {
        case .sedentary: return .sedentary
        case .lightlyActive: return .lightlyActive
        case .moderatelyActive: return .moderatelyActive
        case .veryActive: return .veryActive
        case .extraActive: return .extraActive
        }
    }
}

extension ProfileDomain.ActivityLevel {
    func toStorageModel() -> StorageInfra.ActivityLevel {
        switch self {
        case .sedentary: return .sedentary
        case .lightlyActive: return .lightlyActive
        case .moderatelyActive: return .moderatelyActive
        case .veryActive: return .veryActive
        case .extraActive: return .extraActive
        }
    }
}

extension StorageInfra.GoalType {
    func toEntity() -> ProfileDomain.GoalType {
        switch self {
        case .weightLoss: return .weightLoss
        case .weightGain: return .weightGain
        case .maintenance: return .maintenance
        }
    }
}

extension ProfileDomain.GoalType {
    func toStorageModel() -> StorageInfra.GoalType {
        switch self {
        case .weightLoss: return .weightLoss
        case .weightGain: return .weightGain
        case .maintenance: return .maintenance
        }
    }
}
