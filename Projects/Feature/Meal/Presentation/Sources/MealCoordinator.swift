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
public final class MealCoordinator: ObservableObject, Coordinator, SaveCompletable {
    private let dependencies: MealCoordinatorDependency
    public var onSaveComplete: (() -> Void)?
    public var onNavigateToDetail: ((MealRecord) -> Void)?
    public var onNavigateToRecord: (() -> Void)?

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

    @MainActor @ViewBuilder
    public func makeDetailView(for mealId: UUID) -> some View {
        MealDetailByIdContainerView(
            mealId: mealId,
            mealClient: dependencies.mealClient
        )
    }

    @MainActor @ViewBuilder
    public func makeListView() -> some View {
        MealListContainerView(
            userProfileId: dependencies.userProfileId,
            mealClient: dependencies.mealClient,
            onNavigateToDetail: { [weak self] meal in
                self?.onNavigateToDetail?(meal)
            },
            onNavigateToRecord: { [weak self] in
                self?.onNavigateToRecord?()
            }
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
            .onChange(of: store.viewState) { _, newState in
                if newState == .success {
                    onSaveComplete()
                }
            }
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

// MARK: - Detail By ID Container View

private struct MealDetailByIdContainerView: View {
    let mealId: UUID
    let mealClient: MealClient

    @State private var meal: MealRecord?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let meal {
                MealDetailContainerView(meal: meal, mealClient: mealClient)
            } else if let errorMessage {
                ContentUnavailableView(
                    "common.error".localized,
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            }
        }
        .task {
            await loadMeal()
        }
    }

    private func loadMeal() async {
        isLoading = true
        do {
            meal = try await mealClient.fetchMeal(mealId)
            if meal == nil {
                errorMessage = "meal.notFound".localized
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - List Container View

private struct MealListContainerView: View {
    let onNavigateToDetail: (MealRecord) -> Void
    let onNavigateToRecord: () -> Void

    @State private var store: StoreOf<MealListFeature>

    init(
        userProfileId: UUID,
        mealClient: MealClient,
        onNavigateToDetail: @escaping (MealRecord) -> Void,
        onNavigateToRecord: @escaping () -> Void
    ) {
        self.onNavigateToDetail = onNavigateToDetail
        self.onNavigateToRecord = onNavigateToRecord
        self._store = State(
            initialValue: Store(
                initialState: MealListFeature.State(userProfileId: userProfileId)
            ) {
                MealListFeature()
            } withDependencies: {
                $0.mealClient = mealClient
            }
        )
    }

    var body: some View {
        MealListView(
            store: store,
            onNavigateToDetail: onNavigateToDetail,
            onNavigateToRecord: onNavigateToRecord
        )
    }
}
