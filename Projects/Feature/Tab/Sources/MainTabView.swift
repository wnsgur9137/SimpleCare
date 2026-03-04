//
//  MainTabView.swift
//  Features
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import SwiftUI
import BasePresentation
import BaseDomain
import Profile
import Settings

public struct MainTabView: View {
    @ObservedObject var coordinator: TabCoordinator
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var languageRefreshID = UUID()

    public init(coordinator: TabCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        Group {
            if coordinator.isReady {
                TabView(selection: $coordinator.selectedTab) {
                    // Home
                    coordinator.makeHome()
                        .tabItem {
                            Label("tab.home".localized, systemImage: AppTab.home.icon)
                        }
                        .tag(AppTab.home)

                    // Meal
                    coordinator.makeMealList()
                        .tabItem {
                            Label("tab.meal".localized, systemImage: AppTab.meal.icon)
                        }
                        .tag(AppTab.meal)

                    // Exercise
                    coordinator.makeExerciseList()
                        .tabItem {
                            Label("tab.exercise".localized, systemImage: AppTab.exercise.icon)
                        }
                        .tag(AppTab.exercise)

                    // Progress (Weight)
                    coordinator.makeProgress()
                        .tabItem {
                            Label("tab.weight".localized, systemImage: AppTab.progress.icon)
                        }
                        .tag(AppTab.progress)

                    // Calendar
                    coordinator.makeCalendar()
                        .tabItem {
                            Label("tab.calendar".localized, systemImage: AppTab.calendar.icon)
                        }
                        .tag(AppTab.calendar)
                }
                .tabBarMinimizeBehavior(.onScrollDown)
                .sheet(isPresented: $coordinator.showSettings) {
                    NavigationStack {
                        SettingsCoordinator(userProfileId: coordinator.diContainer.userProfileId).start()
                    }
                }
                .sheet(isPresented: $coordinator.showProfile) {
                    NavigationStack {
                        let container = coordinator.diContainer.makeProfileDIContainer()
                        ProfileCoordinator(dependencies: container).start()
                    }
                }
                .sheet(isPresented: $coordinator.showingMealDetail) {
                    if let mealId = coordinator.selectedMealId {
                        coordinator.makeMealDetailView(mealId: mealId)
                    }
                }
                .sheet(isPresented: $coordinator.showingExerciseDetail) {
                    if let exerciseId = coordinator.selectedExerciseId {
                        coordinator.makeExerciseDetailView(exerciseId: exerciseId)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .id(languageRefreshID)
        .onReceive(NotificationCenter.default.publisher(for: .languageDidChange)) { _ in
            languageRefreshID = UUID()
        }
        .task {
            await coordinator.ensureProfileLoaded()
        }
    }
}
