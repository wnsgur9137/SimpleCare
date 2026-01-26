//
//  HomeView.swift
//  HomePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import HomeDomain

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
                    // 날짜 선택
                    dateNavigationSection

                    // AI 인사이트
                    insightSection

                    // 칼로리 요약
                    if let summary = store.dailySummary {
                        calorieSummarySection(summary: summary)

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
                            onAddTap: { store.send(.addRecordButtonTapped) }
                        )

                        // 주간 트렌드
                        HomeWeeklyTrendView(
                            weeklyStatus: store.weeklyStatus,
                            selectedDayIndex: store.selectedDayIndex,
                            onDayTap: { store.send(.selectWeekDay($0)) }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("홈")
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
        }
    }

    // MARK: - Sections

    private var dateNavigationSection: some View {
        HStack {
            Button {
                store.send(.goToPreviousDay)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(store.isToday ? "오늘" : formattedDate)
                    .font(.title3)
                    .fontWeight(.bold)

                if !store.isToday {
                    Text(formattedWeekday)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                store.send(.goToNextDay)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundStyle(store.canGoToNextDay ? Color.secondary : Color.clear)
            }
            .disabled(!store.canGoToNextDay)
        }
        .padding(.horizontal, 8)
    }

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
        .background(insightBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var insightBackgroundColor: Color {
        guard let summary = store.dailySummary else {
            return Color.blue.opacity(0.1)
        }
        switch summary.calorieStatus {
        case .under: return Color.orange.opacity(0.1)
        case .onTrack: return Color.green.opacity(0.1)
        case .over: return Color.red.opacity(0.1)
        }
    }

    private func calorieSummarySection(summary: HomeDailySummary) -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                Spacer()

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

                Spacer()

                // 스트릭 배지
                if summary.streakDays > 0 {
                    HomeStreakBadge(days: summary.streakDays)
                }

                Spacer()
            }

            // 남은 칼로리 / 운동 소모
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("남은")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(summary.remainingCalories)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(summary.remainingCalories >= 0 ? .green : .red)
                    Text("kcal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if summary.exerciseCalories > 0 {
                    VStack(spacing: 4) {
                        Text("운동")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("+\(summary.exerciseCalories)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                        Text("kcal")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: store.selectedDate)
    }

    private var formattedWeekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: store.selectedDate)
    }

    private func calorieColor(for status: HomeCalorieStatus) -> Color {
        switch status {
        case .under: return .orange
        case .onTrack: return .green
        case .over: return .red
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
