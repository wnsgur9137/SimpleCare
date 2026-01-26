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
import Dashboard
import Meal
import Weight
import Exercise
import Profile
import BasePresentation

public final class TabCoordinator: ObservableObject, Coordinator {
    private let diContainer: TabDIContainer

    // MARK: - Published Properties

    @Published public var selectedTab: AppTab = .dashboard
    @Published public var showingMealRecord: Bool = false
    @Published public var showingExerciseRecord: Bool = false

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

    // MARK: - Dashboard

    @MainActor
    public func makeDashboard() -> some View {
        let container = diContainer.makeDashboardDIContainer()
        return DashboardCoordinator(dependencies: container).start()
    }

    // MARK: - Meal

    @MainActor
    public func makeMealList() -> some View {
        return NavigationStack {
            VStack {
                // TODO: Implement meal list view
                Text("식사 기록")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)

                Button {
                    self.showingMealRecord = true
                } label: {
                    Label("식사 기록하기", systemImage: "plus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("식단")
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
                Text("운동 기록")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)

                Button {
                    self.showingExerciseRecord = true
                } label: {
                    Label("운동 기록하기", systemImage: "plus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("운동")
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
            List {
                Section("계정") {
                    NavigationLink {
                        let container = diContainer.makeProfileDIContainer()
                        ProfileCoordinator(dependencies: container).start()
                    } label: {
                        Label("프로필 설정", systemImage: "person.circle")
                    }
                }

                Section("앱 정보") {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Text("AI 추정치는 참고용이며 의료적 조언이 아닙니다.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("설정")
        }
    }
}
