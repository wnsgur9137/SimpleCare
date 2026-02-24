//
//  MealCoordinator.swift
//  MealPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import BasePresentation
import MealDomain

public protocol MealCoordinatorDependency {
    var userProfileId: UUID { get }
    var mealClient: MealClient { get }
}

/// Meal Coordinator
public final class MealCoordinator: ObservableObject, Coordinator {
    private let dependencies: MealCoordinatorDependency
    public var onSaveComplete: (() -> Void)?

    public init(dependencies: MealCoordinatorDependency, onSaveComplete: (() -> Void)? = nil) {
        self.dependencies = dependencies
        self.onSaveComplete = onSaveComplete
    }

    @MainActor @ViewBuilder
    public func start() -> some View {
        MealContainerView(
            userProfileId: dependencies.userProfileId,
            mealClient: dependencies.mealClient,
            onSaveComplete: { [weak self] in
                self?.onSaveComplete?()
            }
        )
    }

    @MainActor @ViewBuilder
    public func makeDetailView(for meal: MealRecord) -> some View {
        MealDetailContainerView(
            meal: meal,
            mealClient: dependencies.mealClient
        )
    }
}

// MARK: - Container View

private struct MealContainerView: View {
    let userProfileId: UUID
    let mealClient: MealClient
    let onSaveComplete: () -> Void

    @State private var store: StoreOf<MealFeature>

    init(
        userProfileId: UUID,
        mealClient: MealClient,
        onSaveComplete: @escaping () -> Void
    ) {
        self.userProfileId = userProfileId
        self.mealClient = mealClient
        self.onSaveComplete = onSaveComplete
        self._store = State(
            initialValue: Store(
                initialState: MealFeature.State(userProfileId: userProfileId)
            ) {
                MealFeature()
            } withDependencies: {
                $0.mealClient = mealClient
            }
        )
    }

    var body: some View {
        MealRecordView(store: store)
    }
}

// MARK: - Detail Container View

private struct MealDetailContainerView: View {
    let meal: MealRecord
    let mealClient: MealClient

    @State private var store: StoreOf<MealDetailFeature>

    init(meal: MealRecord, mealClient: MealClient) {
        self.meal = meal
        self.mealClient = mealClient
        self._store = State(
            initialValue: Store(
                initialState: MealDetailFeature.State(meal: meal)
            ) {
                MealDetailFeature()
            } withDependencies: {
                $0.mealClient = mealClient
            }
        )
    }

    var body: some View {
        MealDetailView(store: store)
    }
}
