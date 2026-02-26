//
//  HomeCoordinator.swift
//  HomePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import BasePresentation
import HomeDomain

/// Home Coordinator 의존성
public protocol HomeCoordinatorDependency {
    var userProfileId: UUID { get }
    var goalCalories: Int { get }
    var macroGoals: MacroGoals { get }
    var homeClient: HomeClient { get }
}

/// Home 화면 Coordinator
public final class HomeCoordinator: ObservableObject, Coordinator {
    public typealias Content = AnyView

    private let dependencies: HomeCoordinatorDependency

    // Navigation callbacks
    public var onNavigateToMeal: (() -> Void)?
    public var onNavigateToMealDetail: ((UUID) -> Void)?
    public var onNavigateToExercise: (() -> Void)?
    public var onNavigateToExerciseDetail: ((UUID) -> Void)?
    public var onNavigateToWeight: (() -> Void)?
    public var onNavigateToSettings: (() -> Void)?
    public var onNavigateToProfile: (() -> Void)?

    public init(dependencies: HomeCoordinatorDependency) {
        self.dependencies = dependencies
    }

    @MainActor @ViewBuilder
    public func start() -> some View {
        HomeContainerView(
            userProfileId: dependencies.userProfileId,
            goalCalories: dependencies.goalCalories,
            macroGoals: dependencies.macroGoals,
            homeClient: dependencies.homeClient,
            onNavigateToMeal: { [weak self] in self?.onNavigateToMeal?() },
            onNavigateToMealDetail: { [weak self] id in self?.onNavigateToMealDetail?(id) },
            onNavigateToExercise: { [weak self] in self?.onNavigateToExercise?() },
            onNavigateToExerciseDetail: { [weak self] id in self?.onNavigateToExerciseDetail?(id) },
            onNavigateToWeight: { [weak self] in self?.onNavigateToWeight?() },
            onNavigateToSettings: { [weak self] in self?.onNavigateToSettings?() },
            onNavigateToProfile: { [weak self] in self?.onNavigateToProfile?() }
        )
    }
}

/// Home Container View (TCA Store 생성)
private struct HomeContainerView: View {
    @State private var store: StoreOf<HomeFeature>

    let onNavigateToMeal: () -> Void
    let onNavigateToMealDetail: (UUID) -> Void
    let onNavigateToExercise: () -> Void
    let onNavigateToExerciseDetail: (UUID) -> Void
    let onNavigateToWeight: () -> Void
    let onNavigateToSettings: () -> Void
    let onNavigateToProfile: () -> Void

    init(
        userProfileId: UUID,
        goalCalories: Int,
        macroGoals: MacroGoals,
        homeClient: HomeClient,
        onNavigateToMeal: @escaping () -> Void,
        onNavigateToMealDetail: @escaping (UUID) -> Void,
        onNavigateToExercise: @escaping () -> Void,
        onNavigateToExerciseDetail: @escaping (UUID) -> Void,
        onNavigateToWeight: @escaping () -> Void,
        onNavigateToSettings: @escaping () -> Void,
        onNavigateToProfile: @escaping () -> Void
    ) {
        self._store = State(
            initialValue: Store(
                initialState: HomeFeature.State(
                    userProfileId: userProfileId,
                    goalCalories: goalCalories,
                    macroGoals: macroGoals
                )
            ) {
                HomeFeature()
            } withDependencies: {
                $0.homeClient = homeClient
            }
        )
        self.onNavigateToMeal = onNavigateToMeal
        self.onNavigateToMealDetail = onNavigateToMealDetail
        self.onNavigateToExercise = onNavigateToExercise
        self.onNavigateToExerciseDetail = onNavigateToExerciseDetail
        self.onNavigateToWeight = onNavigateToWeight
        self.onNavigateToSettings = onNavigateToSettings
        self.onNavigateToProfile = onNavigateToProfile
    }

    var body: some View {
        HomeView(store: store)
            .onChange(of: store.pendingNavigation) { _, newValue in
                guard let target = newValue else { return }
                switch target {
                case .meal: onNavigateToMeal()
                case .mealDetail(let id): onNavigateToMealDetail(id)
                case .exercise: onNavigateToExercise()
                case .exerciseDetail(let id): onNavigateToExerciseDetail(id)
                case .weight: onNavigateToWeight()
                case .settings: onNavigateToSettings()
                case .profile: onNavigateToProfile()
                }
                store.send(.navigationHandled)
            }
    }
}
