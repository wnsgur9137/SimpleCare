//
//  ExerciseCoordinator.swift
//  ExercisePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import BasePresentation
import ExerciseDomain

public protocol ExerciseCoordinatorDependency {
    var userProfileId: UUID { get }
    var userWeightKg: Double { get }
    var exerciseClient: ExerciseClient { get }
}

public final class ExerciseCoordinator: ObservableObject, Coordinator {
    private let dependencies: ExerciseCoordinatorDependency
    public var onSaveComplete: (() -> Void)?

    public init(dependencies: ExerciseCoordinatorDependency, onSaveComplete: (() -> Void)? = nil) {
        self.dependencies = dependencies
        self.onSaveComplete = onSaveComplete
    }

    @MainActor @ViewBuilder
    public func start() -> some View {
        ExerciseContainerView(
            userProfileId: dependencies.userProfileId,
            userWeightKg: dependencies.userWeightKg,
            exerciseClient: dependencies.exerciseClient,
            onSaveComplete: { [weak self] in
                self?.onSaveComplete?()
            }
        )
    }
}

// MARK: - Container View

private struct ExerciseContainerView: View {
    let userProfileId: UUID
    let userWeightKg: Double
    let exerciseClient: ExerciseClient
    let onSaveComplete: () -> Void

    @State private var store: StoreOf<ExerciseFeature>
    @Environment(\.dismiss) private var dismiss

    init(
        userProfileId: UUID,
        userWeightKg: Double,
        exerciseClient: ExerciseClient,
        onSaveComplete: @escaping () -> Void
    ) {
        self.userProfileId = userProfileId
        self.userWeightKg = userWeightKg
        self.exerciseClient = exerciseClient
        self.onSaveComplete = onSaveComplete
        self._store = State(
            initialValue: Store(
                initialState: ExerciseFeature.State(
                    userProfileId: userProfileId,
                    userWeightKg: userWeightKg
                )
            ) {
                ExerciseFeature()
            } withDependencies: {
                $0.exerciseClient = exerciseClient
            }
        )
    }

    var body: some View {
        ExerciseRecordView(store: store)
            .onChange(of: store.isLoading) { oldValue, newValue in
                // Delegate 액션 관찰을 위한 간접적 방식
                // saveExerciseResponse(.success) 후 isLoading이 false가 되면
                // 저장 완료로 간주
            }
    }
}
