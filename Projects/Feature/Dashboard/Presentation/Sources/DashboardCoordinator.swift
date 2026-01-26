//
//  DashboardCoordinator.swift
//  DashboardPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import BasePresentation
import DashboardDomain

public protocol DashboardCoordinatorDependency {
    var userProfileId: UUID { get }
    var goalCalories: Int { get }
    var getDailySummary: @Sendable (Date, UUID, Int) async throws -> DailySummary { get }
    var generateDailyInsight: @Sendable (DailySummary, [String]) async throws -> DailyInsight { get }
}

/// Dashboard Coordinator
public final class DashboardCoordinator: ObservableObject, Coordinator {
    private let dependencies: DashboardCoordinatorDependency

    public init(dependencies: DashboardCoordinatorDependency) {
        self.dependencies = dependencies
    }

    @MainActor @ViewBuilder
    public func start() -> some View {
        DashboardContainerView(
            userProfileId: dependencies.userProfileId,
            goalCalories: dependencies.goalCalories,
            getDailySummary: dependencies.getDailySummary,
            generateDailyInsight: dependencies.generateDailyInsight
        )
    }
}

// MARK: - Container View

private struct DashboardContainerView: View {
    let userProfileId: UUID
    let goalCalories: Int
    let getDailySummary: @Sendable (Date, UUID, Int) async throws -> DailySummary
    let generateDailyInsight: @Sendable (DailySummary, [String]) async throws -> DailyInsight

    @State private var store: StoreOf<DashboardFeature>

    init(
        userProfileId: UUID,
        goalCalories: Int,
        getDailySummary: @escaping @Sendable (Date, UUID, Int) async throws -> DailySummary,
        generateDailyInsight: @escaping @Sendable (DailySummary, [String]) async throws -> DailyInsight
    ) {
        self.userProfileId = userProfileId
        self.goalCalories = goalCalories
        self.getDailySummary = getDailySummary
        self.generateDailyInsight = generateDailyInsight
        self._store = State(
            initialValue: Store(
                initialState: DashboardFeature.State(
                    userProfileId: userProfileId,
                    goalCalories: goalCalories
                )
            ) {
                DashboardFeature()
            } withDependencies: {
                $0.getDailySummary = getDailySummary
                $0.generateDailyInsight = generateDailyInsight
            }
        )
    }

    var body: some View {
        DashboardView(store: store)
    }
}
