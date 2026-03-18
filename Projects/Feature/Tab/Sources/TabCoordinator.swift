//
//  TabCoordinator.swift
//  Features
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import SwiftUI

import Home
import Settings
import Calendar
import Meal
import Weight
import Exercise
import Profile
import BasePresentation
import BaseDomain

public final class TabCoordinator: ObservableObject, Coordinator {
    let diContainer: TabDIContainer

    // MARK: - Child Coordinators

    private var homeCoordinator: HomeCoordinator?
    private var mealCoordinator: MealCoordinator?

    // MARK: - Published Properties

    @Published public var selectedTab: AppTab = .home
    @Published public var showingMealRecord: Bool = false
    @Published public var showingMealDetail: Bool = false
    @Published public var selectedMealId: UUID?
    @Published public var showingExerciseRecord: Bool = false
    @Published public var showingExerciseDetail: Bool = false
    @Published public var selectedExerciseId: UUID?
    @Published public var showSettings: Bool = false
    @Published public var showProfile: Bool = false
    @Published public var isReady: Bool = false

    public init(diContainer: TabDIContainer) {
        self.diContainer = diContainer
    }

    // MARK: - Bindings

    private var showingMealRecordBinding: Binding<Bool> {
        Binding(
            get: { self.showingMealRecord },
            set: { self.showingMealRecord = $0 }
        )
    }

    private var showingExerciseRecordBinding: Binding<Bool> {
        Binding(
            get: { self.showingExerciseRecord },
            set: { self.showingExerciseRecord = $0 }
        )
    }

    public func start() -> some View {
        return MainTabView(coordinator: self)
    }

    // MARK: - Profile Preload

    @MainActor
    public func ensureProfileLoaded() async {
        await diContainer.ensureProfileLoaded()
        isReady = true
    }

    // MARK: - Home

    @MainActor
    public func makeHome() -> some View {
        let container = diContainer.makeHomeDIContainer()
        let coordinator = HomeCoordinator(dependencies: container)
        coordinator.onNavigateToMeal = { [weak self] in
            self?.selectedTab = .meal
        }
        coordinator.onNavigateToMealDetail = { [weak self] mealId in
            self?.selectedMealId = mealId
            self?.showingMealDetail = true
        }
        coordinator.onNavigateToExercise = { [weak self] in
            self?.selectedTab = .exercise
        }
        coordinator.onNavigateToExerciseDetail = { [weak self] exerciseId in
            self?.selectedExerciseId = exerciseId
            self?.showingExerciseDetail = true
        }
        coordinator.onNavigateToWeight = { [weak self] in
            self?.selectedTab = .progress
        }
        coordinator.onNavigateToSettings = { [weak self] in
            self?.showSettings = true
        }
        coordinator.onNavigateToProfile = { [weak self] in
            self?.showProfile = true
        }
        self.homeCoordinator = coordinator
        return coordinator.start()
    }

    // MARK: - Meal

    @MainActor
    public func makeMealDetailView(mealId: UUID) -> some View {
        let container = diContainer.makeMealDIContainer()
        return NavigationStack {
            MealCoordinator(dependencies: container).makeDetailView(for: mealId)
        }
    }

    @MainActor
    public func makeMealList() -> some View {
        if mealCoordinator == nil {
            let container = diContainer.makeMealDIContainer()
            let coordinator = MealCoordinator(dependencies: container)
            coordinator.onNavigateToDetail = { [weak self] meal in
                self?.selectedMealId = meal.id
                self?.showingMealDetail = true
            }
            coordinator.onNavigateToRecord = { [weak self] in
                self?.showingMealRecord = true
            }
            coordinator.onSaveComplete = { [weak self] in
                self?.showingMealRecord = false
            }
            self.mealCoordinator = coordinator
        }

        return NavigationStack {
            mealCoordinator!.makeListView()
                .sheet(isPresented: showingMealRecordBinding) {
                    self.makeMealRecordSheet()
                }
        }
    }

    @MainActor
    private func makeMealRecordSheet() -> some View {
        let recordContainer = diContainer.makeMealDIContainer()
        let recordCoordinator = MealCoordinator(dependencies: recordContainer)
        recordCoordinator.onSaveComplete = { [weak self] in
            self?.showingMealRecord = false
        }
        return recordCoordinator.start()
    }

    // MARK: - Exercise

    @MainActor
    public func makeExerciseDetailView(exerciseId: UUID) -> some View {
        let container = diContainer.makeExerciseDIContainer()
        return NavigationStack {
            ExerciseCoordinator(dependencies: container).makeDetailView(for: exerciseId)
        }
    }

    @MainActor
    public func makeExerciseList() -> some View {
        let container = diContainer.makeExerciseDIContainer()
        let coordinator = ExerciseCoordinator(dependencies: container)
        coordinator.onNavigateToDetail = { [weak self] exercise in
            self?.selectedExerciseId = exercise.id
            self?.showingExerciseDetail = true
        }
        coordinator.onNavigateToRecord = { [weak self] in
            self?.showingExerciseRecord = true
        }
        coordinator.onSaveComplete = { [weak self] in
            self?.showingExerciseRecord = false
        }

        return NavigationStack {
            coordinator.makeListView()
                .sheet(isPresented: showingExerciseRecordBinding) {
                    self.makeExerciseRecordSheet()
                }
        }
    }

    @MainActor
    private func makeExerciseRecordSheet() -> some View {
        let recordContainer = diContainer.makeExerciseDIContainer()
        let recordCoordinator = ExerciseCoordinator(dependencies: recordContainer)
        recordCoordinator.onSaveComplete = { [weak self] in
            self?.showingExerciseRecord = false
        }
        return recordCoordinator.start()
    }

    // MARK: - Progress (Weight)

    @MainActor
    public func makeProgress() -> some View {
        let container = diContainer.makeWeightDIContainer()
        return WeightCoordinator(dependencies: container).start()
    }

    // MARK: - Calendar

    @MainActor
    public func makeCalendar() -> some View {
        let container = diContainer.makeCalendarDIContainer()
        let coordinator = CalendarCoordinator(dependencies: container)
        coordinator.onNavigateToMealDetail = { [weak self] mealId in
            self?.selectedMealId = mealId
            self?.showingMealDetail = true
        }
        coordinator.onNavigateToExerciseDetail = { [weak self] exerciseId in
            self?.selectedExerciseId = exerciseId
            self?.showingExerciseDetail = true
        }
        return coordinator.start()
    }
}
