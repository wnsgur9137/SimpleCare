//
//  OnboardingViewModel.swift
//  OnboardingPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import Combine
import OnboardingDomain
import ProfileDomain

/// 온보딩 ViewModel
@MainActor
public final class OnboardingViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public private(set) var currentStep: OnboardingStep = .welcome
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: String?

    // User input
    @Published public var name: String = ""
    @Published public var age: Int = 30
    @Published public var biologicalSex: BiologicalSex = .male
    @Published public var heightCm: Double = 170.0
    @Published public var currentWeightKg: Double = 70.0
    @Published public var targetWeightKg: Double = 65.0
    @Published public var goalType: GoalType = .maintenance
    @Published public var activityLevel: ActivityLevel = .moderatelyActive

    // Computed
    @Published public private(set) var calculatedCalories: Int = 0
    @Published public private(set) var calculatedBMR: Double = 0
    @Published public private(set) var calculatedTDEE: Double = 0

    // MARK: - Dependencies

    private let saveProfileUseCase: SaveUserProfileUseCaseProtocol
    public var onComplete: (() -> Void)?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(saveProfileUseCase: SaveUserProfileUseCaseProtocol) {
        self.saveProfileUseCase = saveProfileUseCase
        setupBindings()
    }

    // MARK: - Public Methods

    public func nextStep() {
        guard let next = currentStep.next else {
            completeOnboarding()
            return
        }
        withAnimation {
            currentStep = next
        }
    }

    public func previousStep() {
        guard let previous = currentStep.previous else { return }
        withAnimation {
            currentStep = previous
        }
    }

    public func goToStep(_ step: OnboardingStep) {
        withAnimation {
            currentStep = step
        }
    }

    public func completeOnboarding() {
        Task {
            await saveProfile()
        }
    }

    public var canProceed: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .basicInfo:
            return !name.isEmpty && age >= 10 && age <= 120
        case .bodyInfo:
            return heightCm >= 100 && heightCm <= 250 &&
                   currentWeightKg >= 30 && currentWeightKg <= 300 &&
                   targetWeightKg >= 30 && targetWeightKg <= 300
        case .goalSetting:
            return true
        case .activityLevel:
            return true
        case .summary:
            return true
        }
    }

    // MARK: - Private Methods

    private func setupBindings() {
        Publishers.CombineLatest4($heightCm, $currentWeightKg, $age, $biologicalSex)
            .combineLatest(Publishers.CombineLatest($activityLevel, $goalType))
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateCalculations()
            }
            .store(in: &cancellables)
    }

    private func updateCalculations() {
        let profile = createProfile()
        calculatedBMR = profile.bmr
        calculatedTDEE = profile.tdee
        calculatedCalories = profile.recommendedDailyCalories
    }

    private func createProfile() -> UserProfile {
        UserProfile(
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
    }

    private func saveProfile() async {
        isLoading = true
        error = nil

        do {
            let profile = createProfile()
            try await saveProfileUseCase.execute(profile: profile)
            isLoading = false
            onComplete?()
        } catch {
            isLoading = false
            self.error = error.localizedDescription
        }
    }

    private func withAnimation(_ action: () -> Void) {
        // SwiftUI animation wrapper will be applied in View
        action()
    }
}
