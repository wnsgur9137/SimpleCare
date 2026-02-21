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
import Meal
import Weight
import Exercise
import Profile
import BasePresentation
import BaseDomain

public final class TabCoordinator: ObservableObject, Coordinator {
    private let diContainer: TabDIContainer

    // MARK: - Published Properties

    @Published public var selectedTab: AppTab = .home
    @Published public var showingMealRecord: Bool = false
    @Published public var showingExerciseRecord: Bool = false
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
        coordinator.onNavigateToExercise = { [weak self] in
            self?.selectedTab = .exercise
        }
        coordinator.onNavigateToWeight = { [weak self] in
            self?.selectedTab = .progress
        }
        return coordinator.start()
    }

    // MARK: - Meal

    @MainActor
    public func makeMealList() -> some View {
        return NavigationStack {
            VStack {
                // TODO: Implement meal list view
                Text("meal.recordTitle".localized)
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)

                Button {
                    self.showingMealRecord = true
                } label: {
                    Label("meal.addMeal".localized, systemImage: "plus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("tab.meal".localized)
            .sheet(isPresented: showingMealRecordBinding) { [weak self] in
                if let self {
                    let container = self.diContainer.makeMealDIContainer()
                    MealCoordinator(dependencies: container).start()
                }
            }
        }
    }

    // MARK: - Exercise

    @MainActor
    public func makeExerciseList() -> some View {
        return NavigationStack {
            VStack {
                // TODO: Implement exercise list view
                Text("exercise.recordTitle".localized)
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)

                Button {
                    self.showingExerciseRecord = true
                } label: {
                    Label("exercise.addExercise".localized, systemImage: "plus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("tab.exercise".localized)
            .sheet(isPresented: showingExerciseRecordBinding) { [weak self] in
                if let self {
                    let container = self.diContainer.makeExerciseDIContainer()
                    ExerciseCoordinator(dependencies: container).start()
                }
            }
        }
    }

    // MARK: - Progress (Weight)

    @MainActor
    public func makeProgress() -> some View {
        let container = diContainer.makeWeightDIContainer()
        return WeightCoordinator(dependencies: container).start()
    }

    // MARK: - Settings

    public func makeSettings() -> some View {
        return NavigationStack {
            SettingsContentView(diContainer: diContainer)
        }
    }
}

// MARK: - Settings Content View

struct SettingsContentView: View {
    let diContainer: TabDIContainer
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var refreshID = UUID()

    var body: some View {
        List {
            Section("settings.account".localized) {
                NavigationLink {
                    let container = diContainer.makeProfileDIContainer()
                    ProfileCoordinator(dependencies: container).start()
                } label: {
                    Label("settings.profile".localized, systemImage: "person.circle")
                }
            }

            Section("settings.theme".localized) {
                ForEach(AppTheme.allCases) { theme in
                    Button {
                        themeManager.setTheme(theme)
                    } label: {
                        HStack {
                            Image(systemName: theme.icon)
                                .foregroundStyle(themeIconColor(for: theme))
                                .frame(width: 24)
                            Text(theme.displayName)
                                .foregroundStyle(.primary)
                            Spacer()
                            if themeManager.currentTheme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }

            Section("settings.language".localized) {
                ForEach(AppLanguage.allCases) { language in
                    Button {
                        localizationManager.setLanguage(language)
                        refreshID = UUID()
                    } label: {
                        HStack {
                            Text(language.displayName)
                                .foregroundStyle(.primary)
                            Spacer()
                            if localizationManager.currentLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }

            Section("settings.appInfo".localized) {
                HStack {
                    Text("settings.version".localized)
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Text("onboarding.disclaimer".localized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("settings.title".localized)
        .id(refreshID)
    }

    private func themeIconColor(for theme: AppTheme) -> Color {
        switch theme {
        case .system:
            return .primary
        case .light:
            return .orange
        case .dark:
            return .indigo
        }
    }
}
