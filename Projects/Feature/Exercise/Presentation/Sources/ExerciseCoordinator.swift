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

public final class ExerciseCoordinator: ObservableObject, Coordinator, SaveCompletable {
    private let dependencies: ExerciseCoordinatorDependency
    public var onSaveComplete: (() -> Void)?
    public var onNavigateToDetail: ((ExerciseRecord) -> Void)?
    public var onNavigateToRecord: (() -> Void)?

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

    @MainActor @ViewBuilder
    public func makeDetailView(for exerciseId: UUID) -> some View {
        ExerciseDetailByIdContainerView(
            exerciseId: exerciseId,
            exerciseClient: dependencies.exerciseClient
        )
    }

    @MainActor @ViewBuilder
    public func makeDetailView(for exercise: ExerciseRecord) -> some View {
        ExerciseDetailContainerView(
            exercise: exercise,
            exerciseClient: dependencies.exerciseClient
        )
    }

    @MainActor @ViewBuilder
    public func makeListView() -> some View {
        ExerciseListContainerView(
            userProfileId: dependencies.userProfileId,
            exerciseClient: dependencies.exerciseClient,
            onNavigateToDetail: { [weak self] exercise in
                self?.onNavigateToDetail?(exercise)
            },
            onNavigateToRecord: { [weak self] in
                self?.onNavigateToRecord?()
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
                if oldValue == true && newValue == false && store.error == nil {
                    onSaveComplete()
                }
            }
    }
}

// MARK: - Detail By ID Container View

private struct ExerciseDetailByIdContainerView: View {
    let exerciseId: UUID
    let exerciseClient: ExerciseClient

    @State private var exercise: ExerciseRecord?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let exercise {
                ExerciseDetailContainerView(
                    exercise: exercise,
                    exerciseClient: exerciseClient
                )
            } else {
                ContentUnavailableView(
                    "exercise.notFound".localized,
                    systemImage: "figure.run.circle",
                    description: Text(errorMessage ?? "")
                )
            }
        }
        .task {
            await loadExercise()
        }
    }

    private func loadExercise() async {
        isLoading = true
        do {
            exercise = try await exerciseClient.fetchExercise(exerciseId)
        } catch {
            errorMessage = error.userMessage
        }
        isLoading = false
    }
}

// MARK: - Detail Container View

struct ExerciseDetailContainerView: View {
    let exercise: ExerciseRecord
    let exerciseClient: ExerciseClient

    @State private var store: StoreOf<ExerciseDetailFeature>
    @Environment(\.dismiss) private var dismiss

    init(exercise: ExerciseRecord, exerciseClient: ExerciseClient) {
        self.exercise = exercise
        self.exerciseClient = exerciseClient
        self._store = State(
            initialValue: Store(
                initialState: ExerciseDetailFeature.State(exercise: exercise)
            ) {
                ExerciseDetailFeature()
            } withDependencies: {
                $0.exerciseClient = exerciseClient
            }
        )
    }

    var body: some View {
        ExerciseDetailView(store: store)
    }
}

// MARK: - List Container View

struct ExerciseListContainerView: View {
    let onNavigateToDetail: (ExerciseRecord) -> Void
    let onNavigateToRecord: () -> Void

    @State private var store: StoreOf<ExerciseListFeature>

    init(
        userProfileId: UUID,
        exerciseClient: ExerciseClient,
        onNavigateToDetail: @escaping (ExerciseRecord) -> Void,
        onNavigateToRecord: @escaping () -> Void
    ) {
        self.onNavigateToDetail = onNavigateToDetail
        self.onNavigateToRecord = onNavigateToRecord
        self._store = State(
            initialValue: Store(
                initialState: ExerciseListFeature.State(userProfileId: userProfileId)
            ) {
                ExerciseListFeature()
            } withDependencies: {
                $0.exerciseClient = exerciseClient
            }
        )
    }

    var body: some View {
        ExerciseListView(store: store)
            .onChange(of: store.selectedExerciseForDetail) { _, exercise in
                if let exercise {
                    onNavigateToDetail(exercise)
                    store.send(.resetNavigation)
                }
            }
            .onChange(of: store.shouldNavigateToRecord) { _, shouldNavigate in
                if shouldNavigate {
                    onNavigateToRecord()
                    store.send(.resetNavigation)
                }
            }
    }
}
