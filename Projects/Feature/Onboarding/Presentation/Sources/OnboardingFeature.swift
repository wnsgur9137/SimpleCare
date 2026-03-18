//
//  OnboardingFeature.swift
//  OnboardingPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import ComposableArchitecture
import OnboardingDomain
import ProfileDomain

@Reducer
public struct OnboardingFeature {
    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var currentStep: OnboardingStep = .welcome
        public var isLoading: Bool = false
        public var isCompleted: Bool = false
        public var error: String?

        // User input
        public var name: String = ""
        public var age: Int = 30
        public var biologicalSex: BiologicalSex = .male
        public var heightCm: Double = 170.0
        public var currentWeightKg: Double = 70.0
        public var targetWeightKg: Double = 65.0
        public var goalType: GoalType = .maintenance
        public var activityLevel: ActivityLevel = .moderatelyActive

        // Computed values
        public var calculatedCalories: Int = 0
        public var calculatedBMR: Double = 0
        public var calculatedTDEE: Double = 0

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

        public init() {
            updateCalculations()
        }

        mutating func updateCalculations() {
            let profile = UserProfile(
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
            calculatedBMR = profile.bmr
            calculatedTDEE = profile.tdee
            calculatedCalories = profile.recommendedDailyCalories
        }
    }

    // MARK: - Action

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case nextStep
        case previousStep
        case goToStep(OnboardingStep)
        case completeOnboarding
        case saveProfileResponse(Result<Void, Error>)
        case updateCalculations
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case onboardingCompleted
        }

        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.binding(let l), .binding(let r)):
                return l == r
            case (.nextStep, .nextStep):
                return true
            case (.previousStep, .previousStep):
                return true
            case (.goToStep(let l), .goToStep(let r)):
                return l == r
            case (.completeOnboarding, .completeOnboarding):
                return true
            case (.saveProfileResponse(.success), .saveProfileResponse(.success)):
                return true
            case (.saveProfileResponse(.failure), .saveProfileResponse(.failure)):
                return true
            case (.updateCalculations, .updateCalculations):
                return true
            case (.delegate(let l), .delegate(let r)):
                return l == r
            default:
                return false
            }
        }
    }

    // MARK: - Dependencies

    @Dependency(\.saveUserProfile) var saveUserProfile

    // MARK: - Reducer

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.heightCm) { _, _ in
                Reduce { state, _ in
                    state.updateCalculations()
                    return .none
                }
            }
            .onChange(of: \.currentWeightKg) { _, _ in
                Reduce { state, _ in
                    state.updateCalculations()
                    return .none
                }
            }
            .onChange(of: \.age) { _, _ in
                Reduce { state, _ in
                    state.updateCalculations()
                    return .none
                }
            }
            .onChange(of: \.biologicalSex) { _, _ in
                Reduce { state, _ in
                    state.updateCalculations()
                    return .none
                }
            }
            .onChange(of: \.activityLevel) { _, _ in
                Reduce { state, _ in
                    state.updateCalculations()
                    return .none
                }
            }
            .onChange(of: \.goalType) { _, _ in
                Reduce { state, _ in
                    state.updateCalculations()
                    return .none
                }
            }

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .nextStep:
                guard let next = state.currentStep.next else {
                    return .send(.completeOnboarding)
                }
                state.currentStep = next
                return .none

            case .previousStep:
                guard let previous = state.currentStep.previous else {
                    return .none
                }
                state.currentStep = previous
                return .none

            case .goToStep(let step):
                state.currentStep = step
                return .none

            case .completeOnboarding:
                state.isLoading = true
                state.error = nil

                let profile = UserProfile(
                    name: state.name,
                    heightCm: state.heightCm,
                    currentWeightKg: state.currentWeightKg,
                    targetWeightKg: state.targetWeightKg,
                    age: state.age,
                    biologicalSex: state.biologicalSex,
                    activityLevel: state.activityLevel,
                    goalType: state.goalType,
                    isOnboardingCompleted: true
                )

                return .run { send in
                    do {
                        try await saveUserProfile(profile)
                        await send(.saveProfileResponse(.success(())))
                    } catch {
                        await send(.saveProfileResponse(.failure(error)))
                    }
                }

            case .saveProfileResponse(.success):
                state.isLoading = false
                state.isCompleted = true
                return .send(.delegate(.onboardingCompleted))

            case .saveProfileResponse(.failure(let error)):
                state.isLoading = false
                state.error = error.userMessage
                return .none

            case .updateCalculations:
                state.updateCalculations()
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
