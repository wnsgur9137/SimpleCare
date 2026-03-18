//
//  ProfileFeature.swift
//  ProfilePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import ComposableArchitecture
import ProfileDomain

@Reducer
public struct ProfileFeature {
    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var viewState: ViewState = .idle
        public var name: String = ""
        public var heightCm: Double = 170.0
        public var currentWeightKg: Double = 70.0
        public var targetWeightKg: Double = 65.0
        public var age: Int = 30
        public var biologicalSex: BiologicalSex = .male
        public var activityLevel: ActivityLevel = .moderatelyActive
        public var goalType: GoalType = .maintenance

        public var calculatedBMR: Double = 0
        public var calculatedTDEE: Double = 0
        public var recommendedCalories: Int = 0
        public var calculatedBMI: Double = 0
        public var bmiCategory: String = ""

        var currentProfile: UserProfile?

        public enum ViewState: Equatable {
            case idle
            case loading
            case loaded(UserProfile)
            case error(String)
        }

        public init() {
            updateCalculations()
        }

        mutating func updateCalculations() {
            let profile = createProfile()
            calculatedBMR = profile.bmr
            calculatedTDEE = profile.tdee
            recommendedCalories = profile.recommendedDailyCalories
            calculatedBMI = profile.bmi
            bmiCategory = profile.bmiCategory
        }

        func createProfile() -> UserProfile {
            UserProfile(
                id: currentProfile?.id ?? UUID(),
                name: name,
                heightCm: heightCm,
                currentWeightKg: currentWeightKg,
                targetWeightKg: targetWeightKg,
                age: age,
                biologicalSex: biologicalSex,
                activityLevel: activityLevel,
                goalType: goalType,
                isOnboardingCompleted: true,
                createdAt: currentProfile?.createdAt ?? Date(),
                updatedAt: Date()
            )
        }
    }

    // MARK: - Action

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case loadProfile
        case loadProfileResponse(Result<UserProfile?, Error>)
        case saveProfile
        case saveProfileResponse(Result<Void, Error>)
        case updateCalculations

        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.binding(let l), .binding(let r)):
                return l == r
            case (.onAppear, .onAppear):
                return true
            case (.loadProfile, .loadProfile):
                return true
            case (.loadProfileResponse(.success(let l)), .loadProfileResponse(.success(let r))):
                return l == r
            case (.loadProfileResponse(.failure), .loadProfileResponse(.failure)):
                return true
            case (.saveProfile, .saveProfile):
                return true
            case (.saveProfileResponse(.success), .saveProfileResponse(.success)):
                return true
            case (.saveProfileResponse(.failure), .saveProfileResponse(.failure)):
                return true
            case (.updateCalculations, .updateCalculations):
                return true
            default:
                return false
            }
        }
    }

    // MARK: - Dependencies

    @Dependency(\.profileClient) var profileClient

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

            case .onAppear:
                return .send(.loadProfile)

            case .loadProfile:
                state.viewState = .loading
                return .run { send in
                    do {
                        let profile = try await profileClient.getProfile()
                        await send(.loadProfileResponse(.success(profile)))
                    } catch {
                        await send(.loadProfileResponse(.failure(error)))
                    }
                }

            case .loadProfileResponse(.success(let profile)):
                if let profile {
                    state.currentProfile = profile
                    state.name = profile.name
                    state.heightCm = profile.heightCm
                    state.currentWeightKg = profile.currentWeightKg
                    state.targetWeightKg = profile.targetWeightKg
                    state.age = profile.age
                    state.biologicalSex = profile.biologicalSex
                    state.activityLevel = profile.activityLevel
                    state.goalType = profile.goalType
                    state.viewState = .loaded(profile)
                } else {
                    state.updateCalculations()
                    state.viewState = .idle
                }
                return .none

            case .loadProfileResponse(.failure(let error)):
                state.viewState = .error(error.userMessage)
                return .none

            case .saveProfile:
                state.viewState = .loading
                let profile = state.createProfile()
                let isUpdate = state.currentProfile != nil

                return .run { send in
                    do {
                        if isUpdate {
                            try await profileClient.updateProfile(profile)
                        } else {
                            try await profileClient.saveProfile(profile)
                        }
                        await send(.saveProfileResponse(.success(())))
                    } catch {
                        await send(.saveProfileResponse(.failure(error)))
                    }
                }

            case .saveProfileResponse(.success):
                let profile = state.createProfile()
                state.currentProfile = profile
                state.viewState = .loaded(profile)
                return .none

            case .saveProfileResponse(.failure(let error)):
                state.viewState = .error(error.userMessage)
                return .none

            case .updateCalculations:
                state.updateCalculations()
                return .none
            }
        }
    }
}

// MARK: - Dependencies

public struct ProfileClient {
    public var getProfile: @Sendable () async throws -> UserProfile?
    public var saveProfile: @Sendable (UserProfile) async throws -> Void
    public var updateProfile: @Sendable (UserProfile) async throws -> Void

    public init(
        getProfile: @escaping @Sendable () async throws -> UserProfile?,
        saveProfile: @escaping @Sendable (UserProfile) async throws -> Void,
        updateProfile: @escaping @Sendable (UserProfile) async throws -> Void
    ) {
        self.getProfile = getProfile
        self.saveProfile = saveProfile
        self.updateProfile = updateProfile
    }
}

extension ProfileClient: DependencyKey {
    public static var liveValue: ProfileClient {
        ProfileClient(
            getProfile: { nil },
            saveProfile: { _ in },
            updateProfile: { _ in }
        )
    }

    public static var testValue: ProfileClient {
        ProfileClient(
            getProfile: {
                UserProfile(
                    name: "테스트",
                    heightCm: 175,
                    currentWeightKg: 70,
                    targetWeightKg: 65,
                    age: 30,
                    biologicalSex: .male,
                    activityLevel: .moderatelyActive,
                    goalType: .weightLoss,
                    isOnboardingCompleted: true
                )
            },
            saveProfile: { _ in },
            updateProfile: { _ in }
        )
    }
}

extension DependencyValues {
    public var profileClient: ProfileClient {
        get { self[ProfileClient.self] }
        set { self[ProfileClient.self] = newValue }
    }
}
