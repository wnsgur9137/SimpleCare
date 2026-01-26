//
//  ProfileViewModel.swift
//  ProfilePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import Combine
import ProfileDomain

/// 프로필 화면 상태
public enum ProfileViewState: Equatable {
    case idle
    case loading
    case loaded(UserProfile)
    case error(String)
}

/// 프로필 ViewModel
@MainActor
public final class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public private(set) var state: ProfileViewState = .idle
    @Published public var name: String = ""
    @Published public var heightCm: Double = 170.0
    @Published public var currentWeightKg: Double = 70.0
    @Published public var targetWeightKg: Double = 65.0
    @Published public var age: Int = 30
    @Published public var biologicalSex: BiologicalSex = .male
    @Published public var activityLevel: ActivityLevel = .moderatelyActive
    @Published public var goalType: GoalType = .maintenance

    @Published public private(set) var calculatedBMR: Double = 0
    @Published public private(set) var calculatedTDEE: Double = 0
    @Published public private(set) var recommendedCalories: Int = 0

    // MARK: - Dependencies

    private let getProfileUseCase: GetUserProfileUseCaseProtocol
    private let saveProfileUseCase: SaveUserProfileUseCaseProtocol
    private let updateProfileUseCase: UpdateUserProfileUseCaseProtocol

    private var cancellables = Set<AnyCancellable>()
    private var currentProfile: UserProfile?

    // MARK: - Initialization

    public init(
        getProfileUseCase: GetUserProfileUseCaseProtocol,
        saveProfileUseCase: SaveUserProfileUseCaseProtocol,
        updateProfileUseCase: UpdateUserProfileUseCaseProtocol
    ) {
        self.getProfileUseCase = getProfileUseCase
        self.saveProfileUseCase = saveProfileUseCase
        self.updateProfileUseCase = updateProfileUseCase

        setupBindings()
    }

    // MARK: - Public Methods

    public func loadProfile() async {
        state = .loading

        do {
            if let profile = try await getProfileUseCase.execute() {
                currentProfile = profile
                updateFormFields(from: profile)
                state = .loaded(profile)
            } else {
                // 신규 사용자 - 기본값 사용
                let newProfile = createProfileFromForm()
                updateCalculations()
                state = .idle
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    public func saveProfile() async throws {
        var profile = createProfileFromForm()

        if let existing = currentProfile {
            profile = UserProfile(
                id: existing.id,
                name: name,
                heightCm: heightCm,
                currentWeightKg: currentWeightKg,
                targetWeightKg: targetWeightKg,
                age: age,
                biologicalSex: biologicalSex,
                activityLevel: activityLevel,
                goalType: goalType,
                dailyCalorieGoal: nil,
                dailyProteinGoal: nil,
                dailyCarbsGoal: nil,
                dailyFatGoal: nil,
                isOnboardingCompleted: true,
                createdAt: existing.createdAt,
                updatedAt: Date()
            )
            try await updateProfileUseCase.execute(profile: profile)
        } else {
            profile = UserProfile(
                name: name,
                heightCm: heightCm,
                currentWeightKg: currentWeightKg,
                targetWeightKg: targetWeightKg,
                age: age,
                biologicalSex: biologicalSex,
                activityLevel: activityLevel,
                goalType: goalType,
                isOnboardingCompleted: true
            )
            try await saveProfileUseCase.execute(profile: profile)
        }

        currentProfile = profile
        state = .loaded(profile)
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // 값이 변경될 때마다 계산값 업데이트
        Publishers.CombineLatest4($heightCm, $currentWeightKg, $age, $biologicalSex)
            .combineLatest(Publishers.CombineLatest($activityLevel, $goalType))
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateCalculations()
            }
            .store(in: &cancellables)
    }

    private func updateFormFields(from profile: UserProfile) {
        name = profile.name
        heightCm = profile.heightCm
        currentWeightKg = profile.currentWeightKg
        targetWeightKg = profile.targetWeightKg
        age = profile.age
        biologicalSex = profile.biologicalSex
        activityLevel = profile.activityLevel
        goalType = profile.goalType
    }

    private func createProfileFromForm() -> UserProfile {
        UserProfile(
            name: name,
            heightCm: heightCm,
            currentWeightKg: currentWeightKg,
            targetWeightKg: targetWeightKg,
            age: age,
            biologicalSex: biologicalSex,
            activityLevel: activityLevel,
            goalType: goalType
        )
    }

    private func updateCalculations() {
        let profile = createProfileFromForm()
        calculatedBMR = profile.bmr
        calculatedTDEE = profile.tdee
        recommendedCalories = profile.recommendedDailyCalories
    }
}
