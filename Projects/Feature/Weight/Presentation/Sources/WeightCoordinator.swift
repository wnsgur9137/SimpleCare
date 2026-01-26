//
//  WeightCoordinator.swift
//  WeightPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import BasePresentation
import WeightDomain

public protocol WeightCoordinatorDependency {
    var userProfileId: UUID { get }
    var currentWeight: Double { get }
    var targetWeight: Double { get }
    var weightClient: WeightClient { get }
}

public final class WeightCoordinator: ObservableObject, @MainActor Coordinator {
    private let dependencies: WeightCoordinatorDependency

    public init(dependencies: WeightCoordinatorDependency) {
        self.dependencies = dependencies
    }

    @MainActor @ViewBuilder
    public func start() -> some View {
        WeightContainerView(
            userProfileId: dependencies.userProfileId,
            currentWeight: dependencies.currentWeight,
            targetWeight: dependencies.targetWeight,
            weightClient: dependencies.weightClient
        )
    }
}

// MARK: - Container View

private struct WeightContainerView: View {
    let userProfileId: UUID
    let currentWeight: Double
    let targetWeight: Double
    let weightClient: WeightClient

    @State private var store: StoreOf<WeightFeature>

    init(
        userProfileId: UUID,
        currentWeight: Double,
        targetWeight: Double,
        weightClient: WeightClient
    ) {
        self.userProfileId = userProfileId
        self.currentWeight = currentWeight
        self.targetWeight = targetWeight
        self.weightClient = weightClient
        self._store = State(
            initialValue: Store(
                initialState: WeightFeature.State(
                    userProfileId: userProfileId,
                    currentWeight: currentWeight,
                    targetWeight: targetWeight
                )
            ) {
                WeightFeature()
            } withDependencies: {
                $0.weightClient = weightClient
            }
        )
    }

    var body: some View {
        WeightView(store: store)
    }
}
