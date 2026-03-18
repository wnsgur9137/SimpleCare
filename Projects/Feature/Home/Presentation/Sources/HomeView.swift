//
//  HomeView.swift
//  HomePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import HomeDomain
import BasePresentation

/// 홈 메인 화면
public struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // AI 인사이트
                    insightSection

                    // 칼로리 요약
                    if let summary = store.dailySummary {
                        calorieSummarySection(summary: summary)

                        // 걸음수 / 활동 칼로리 (HealthKit)
                        if store.isHealthKitAvailable {
                            healthKitSection(summary: summary)
                        }

                        // 영양소 프로그레스
                        HomeNutritionSection(summary: summary)

                        // 빠른 기록 버튼
                        HomeQuickActionButtons(
                            onMealTap: { store.send(.mealButtonTapped) },
                            onExerciseTap: { store.send(.exerciseButtonTapped) },
                            onWeightTap: { store.send(.weightButtonTapped) }
                        )

                        // 오늘의 기록 목록
                        HomeTodayRecordsSection(
                            meals: summary.meals,
                            exercises: summary.exercises,
                            onAddTap: { store.send(.addRecordButtonTapped) },
                            onMealTap: { mealId in store.send(.mealDetailTapped(mealId)) },
                            onExerciseTap: { exerciseId in store.send(.exerciseDetailTapped(exerciseId)) }
                        )

                        // 주간 트렌드
                        HomeWeeklyTrendView(
                            weeklyStatus: store.weeklyStatus,
                            selectedDayIndex: store.selectedDayIndex,
                            onDayTap: { _ in }
                        )

                        // 리포트 진입점
                        reportEntryCard
                    }
                }
                .padding()
            }
            .navigationTitle("tab.home".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(
                    placement: .topBarTrailing,
                    content: {
                        Button {
                            store.send(.profileButtonTapped)
                        } label: {
                            Image(systemName: "person.circle")
                        }
                        .accessibilityLabel("accessibility.home.profile".localized)
                        Button {
                            store.send(.settingsButtonTapped)
                        } label: {
                            Image(systemName: "gearshape")
                        }
                        .accessibilityLabel("accessibility.home.settings".localized)
                    }
                )
            }
            .refreshable {
                await store.send(.refreshData).finish()
            }
            .task {
                store.send(.onAppear)
            }
            .overlay {
                if store.viewState == .loading && store.dailySummary == nil {
                    ProgressView()
                }
            }
            .sheet(isPresented: Binding(
                get: { store.showReport },
                set: { if !$0 { store.send(.dismissReport) } }
            )) {
                ReportView(store: store)
            }
        }
    }

    // MARK: - Sections

    private var insightSection: some View {
        HStack(spacing: 12) {
            Text(store.insight.emoji)
                .font(.largeTitle)

            Text(store.insight.comment)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding()
        .glassEffect(.regular.tint(insightTintColor), in: .rect(cornerRadius: 12))
    }

    private var insightTintColor: Color {
        guard let summary = store.dailySummary else {
            return .scPrimary
        }
        switch summary.calorieStatus {
        case .under: return .scWarning
        case .onTrack: return .scSuccess
        case .over: return .scError
        }
    }

    private func calorieSummarySection(summary: HomeDailySummary) -> some View {
        VStack(spacing: 16) {
            // 원형 프로그레스
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 16)

                Circle()
                    .trim(from: 0, to: min(summary.calorieProgress, 1.0))
                    .stroke(
                        calorieColor(for: summary.calorieStatus),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.5), value: summary.calorieProgress)

                VStack(spacing: 2) {
                    Text("\(summary.totalCalories)")
                        .font(.system(size: 32, weight: .bold))

                    Text("/ \(summary.goalCalories) kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(summary.calorieStatus.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(calorieColor(for: summary.calorieStatus))
                }
            }
            .frame(width: 160, height: 160)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("accessibility.home.calorieProgress".localized(with: summary.totalCalories, summary.goalCalories, Int(summary.calorieProgress * 100)))
            .overlay(alignment: .topTrailing) {
                // 스트릭 배지
                if summary.streakDays > 0 {
                    HomeStreakBadge(days: summary.streakDays)
                        .offset(x: 60, y: -8)
                }
            }

            // 남은 칼로리 / 운동 소모
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("home.remaining".localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(summary.remainingCalories)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(summary.remainingCalories >= 0 ? .scSuccess : .scError)
                    Text("kcal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if summary.exerciseCalories > 0 {
                    VStack(spacing: 4) {
                        Text("tab.exercise".localized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("+\(summary.exerciseCalories)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.scExercise)
                        Text("kcal")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }

    private var reportEntryCard: some View {
        Button {
            store.send(.reportButtonTapped)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.title2)
                    .foregroundStyle(.scPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("home.weeklyReport".localized)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text("home.reportDescription".localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .glassEffect(.regular.tint(.scPrimary.opacity(0.3)), in: .rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func healthKitSection(summary: HomeDailySummary) -> some View {
        if store.isHealthKitAuthorized {
            HStack(spacing: 12) {
                // 걸음수 카드
                HStack(spacing: 8) {
                    Image(systemName: "figure.walk")
                        .font(.title3)
                        .foregroundStyle(.scPrimary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(HomeDomainStrings.Home.steps)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(summary.steps.formatted())")
                            .font(.title3)
                            .fontWeight(.bold)
                    }

                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .glassEffect(.regular, in: .rect(cornerRadius: 12))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("accessibility.home.steps".localized(with: summary.steps))

                // 활동 칼로리 카드
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.title3)
                        .foregroundStyle(.scExercise)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(HomeDomainStrings.Home.activeCalories)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(summary.activeCalories)")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("kcal")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .glassEffect(.regular, in: .rect(cornerRadius: 12))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("accessibility.home.activeCalories".localized(with: summary.activeCalories))
            }
        } else {
            // 건강 권한 미허용 안내
            VStack(spacing: 12) {
                Image(systemName: "heart.text.clipboard")
                    .font(.title2)
                    .foregroundStyle(.scPrimary)

                Text(HomeDomainStrings.Home.HealthKit.permissionRequired)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button {
                    store.send(.openHealthSettingsTapped)
                } label: {
                    Text(HomeDomainStrings.Home.HealthKit.openSettings)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(.scPrimary, in: .capsule)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .glassEffect(.regular, in: .rect(cornerRadius: 12))
        }
    }

    // MARK: - Helpers

    private func calorieColor(for status: HomeCalorieStatus) -> Color {
        switch status {
        case .under: return .scWarning
        case .onTrack: return .scSuccess
        case .over: return .scError
        }
    }
}

#Preview {
    HomeView(
        store: Store(
            initialState: HomeFeature.State(
                userProfileId: UUID(),
                goalCalories: 2000
            )
        ) {
            HomeFeature()
        } withDependencies: {
            $0.homeClient = .testValue
        }
    )
}
