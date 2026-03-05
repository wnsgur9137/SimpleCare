//
//  CalendarCoordinator.swift
//  CalendarPresentation
//
//  Created by JunHyeok Lee on 2/21/26.
//

import SwiftUI
import BasePresentation
import HomeDomain

/// Calendar Coordinator 의존성
public protocol CalendarCoordinatorDependency {
    var userProfileId: UUID { get }
    var goalCalories: Int { get }
    var macroGoals: MacroGoals { get }
    var homeClient: HomeClient { get }
}

/// Calendar 화면 Coordinator
public final class CalendarCoordinator: ObservableObject, Coordinator {
    public typealias Content = AnyView

    private let dependencies: CalendarCoordinatorDependency

    // Navigation callbacks
    public var onNavigateToMealDetail: ((UUID) -> Void)?
    public var onNavigateToExerciseDetail: ((UUID) -> Void)?

    public init(dependencies: CalendarCoordinatorDependency) {
        self.dependencies = dependencies
    }

    @MainActor @ViewBuilder
    public func start() -> some View {
        NavigationStack {
            CalendarContentView(
                userProfileId: dependencies.userProfileId,
                goalCalories: dependencies.goalCalories,
                macroGoals: dependencies.macroGoals,
                homeClient: dependencies.homeClient,
                onNavigateToMealDetail: { [weak self] id in self?.onNavigateToMealDetail?(id) },
                onNavigateToExerciseDetail: { [weak self] id in self?.onNavigateToExerciseDetail?(id) }
            )
        }
    }
}
