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

                    // Settings
                    coordinator.makeSettings()
                        .tabItem {
                            Label("tab.settings".localized, systemImage: AppTab.settings.icon)
                        }
                        .tag(AppTab.settings)
                }
                .tabBarMinimizeBehavior(.onScrollDown)
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
