//
//  MainTabView.swift
//  Features
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import SwiftUI

public struct MainTabView: View {
    @ObservedObject var coordinator: TabCoordinator

    public init(coordinator: TabCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            // Home
            coordinator.makeHome()
                .tabItem {
                    Label(AppTab.home.title, systemImage: AppTab.home.icon)
                }
                .tag(AppTab.home)

            // Meal
            coordinator.makeMealList()
                .tabItem {
                    Label(AppTab.meal.title, systemImage: AppTab.meal.icon)
                }
                .tag(AppTab.meal)

            // Exercise
            coordinator.makeExerciseList()
                .tabItem {
                    Label(AppTab.exercise.title, systemImage: AppTab.exercise.icon)
                }
                .tag(AppTab.exercise)

            // Progress (Weight)
            coordinator.makeProgress()
                .tabItem {
                    Label(AppTab.progress.title, systemImage: AppTab.progress.icon)
                }
                .tag(AppTab.progress)

            // Settings
            coordinator.makeSettings()
                .tabItem {
                    Label(AppTab.settings.title, systemImage: AppTab.settings.icon)
                }
                .tag(AppTab.settings)
        }
    }
}
