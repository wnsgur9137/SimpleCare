//
//  DashboardFeature.swift
//  DashboardPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import ComposableArchitecture
import DashboardDomain

@Reducer
public struct DashboardFeature {
    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var viewState: ViewState = .idle
        public var dailySummary: DailySummary?
        public var insight: DailyInsight = .defaultInsight
        public var selectedDate: Date = Date()
        public var userProfileId: UUID
        public var goalCalories: Int

        public var isToday: Bool {
            Calendar.current.isDateInToday(selectedDate)
        }

        public var canGoToNextDay: Bool {
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            return tomorrow <= Date()
        }

        public enum ViewState: Equatable {
            case idle
            case loading
            case loaded
            case error(String)
        }

        public init(userProfileId: UUID, goalCalories: Int) {
            self.userProfileId = userProfileId
            self.goalCalories = goalCalories
        }
    }

    // MARK: - Action

    public enum Action: Equatable {
        case onAppear
        case loadDashboard
        case refreshData
        case selectDate(Date)
        case goToPreviousDay
        case goToNextDay
        case loadDashboardResponse(Result<DailySummary, Error>)
        case generateInsightResponse(Result<DailyInsight, Error>)

        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.onAppear, .onAppear):
                return true
            case (.loadDashboard, .loadDashboard):
                return true
            case (.refreshData, .refreshData):
                return true
            case (.selectDate(let l), .selectDate(let r)):
                return l == r
            case (.goToPreviousDay, .goToPreviousDay):
                return true
            case (.goToNextDay, .goToNextDay):
                return true
            case (.loadDashboardResponse(.success(let l)), .loadDashboardResponse(.success(let r))):
                return l == r
            case (.loadDashboardResponse(.failure), .loadDashboardResponse(.failure)):
                return true
            case (.generateInsightResponse(.success(let l)), .generateInsightResponse(.success(let r))):
                return l == r
            case (.generateInsightResponse(.failure), .generateInsightResponse(.failure)):
                return true
            default:
                return false
            }
        }
    }

    // MARK: - Dependencies

    @Dependency(\.getDailySummary) var getDailySummary
    @Dependency(\.generateDailyInsight) var generateDailyInsight

    // MARK: - Reducer

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadDashboard)

            case .loadDashboard:
                state.viewState = .loading
                let date = state.selectedDate
                let userProfileId = state.userProfileId
                let goalCalories = state.goalCalories

                return .run { send in
                    do {
                        let summary = try await getDailySummary(date, userProfileId, goalCalories)
                        await send(.loadDashboardResponse(.success(summary)))
                    } catch {
                        await send(.loadDashboardResponse(.failure(error)))
                    }
                }

            case .refreshData:
                return .send(.loadDashboard)

            case .selectDate(let date):
                state.selectedDate = date
                return .send(.loadDashboard)

            case .goToPreviousDay:
                if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: state.selectedDate) {
                    state.selectedDate = newDate
                    return .send(.loadDashboard)
                }
                return .none

            case .goToNextDay:
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: state.selectedDate) ?? state.selectedDate
                if tomorrow <= Date() {
                    state.selectedDate = tomorrow
                    return .send(.loadDashboard)
                }
                return .none

            case .loadDashboardResponse(.success(let summary)):
                state.dailySummary = summary
                state.viewState = .loaded

                return .run { send in
                    do {
                        let insight = try await generateDailyInsight(summary, [])
                        await send(.generateInsightResponse(.success(insight)))
                    } catch {
                        await send(.generateInsightResponse(.failure(error)))
                    }
                }

            case .loadDashboardResponse(.failure(let error)):
                state.viewState = .error(error.localizedDescription)
                return .none

            case .generateInsightResponse(.success(let insight)):
                state.insight = insight
                return .none

            case .generateInsightResponse(.failure):
                state.insight = .defaultInsight
                return .none
            }
        }
    }
}

// MARK: - Dependencies

public struct DashboardClient {
    public var getDailySummary: @Sendable (Date, UUID, Int) async throws -> DailySummary
    public var generateDailyInsight: @Sendable (DailySummary, [String]) async throws -> DailyInsight

    public init(
        getDailySummary: @escaping @Sendable (Date, UUID, Int) async throws -> DailySummary,
        generateDailyInsight: @escaping @Sendable (DailySummary, [String]) async throws -> DailyInsight
    ) {
        self.getDailySummary = getDailySummary
        self.generateDailyInsight = generateDailyInsight
    }
}

extension DashboardClient: DependencyKey {
    public static var liveValue: DashboardClient {
        DashboardClient(
            getDailySummary: { _, _, _ in
                DailySummary(
                    date: Date(),
                    totalCalories: 0,
                    goalCalories: 2000,
                    totalProtein: 0,
                    totalCarbs: 0,
                    totalFat: 0,
                    mealCount: 0
                )
            },
            generateDailyInsight: { _, _ in
                .defaultInsight
            }
        )
    }

    public static var testValue: DashboardClient {
        DashboardClient(
            getDailySummary: { _, _, _ in
                DailySummary(
                    date: Date(),
                    totalCalories: 1500,
                    goalCalories: 2000,
                    totalProtein: 80,
                    totalCarbs: 200,
                    totalFat: 50,
                    mealCount: 3
                )
            },
            generateDailyInsight: { _, _ in
                .defaultInsight
            }
        )
    }
}

extension DependencyValues {
    public var getDailySummary: @Sendable (Date, UUID, Int) async throws -> DailySummary {
        get { self[DashboardClient.self].getDailySummary }
        set { self[DashboardClient.self] = DashboardClient(getDailySummary: newValue, generateDailyInsight: self[DashboardClient.self].generateDailyInsight) }
    }

    public var generateDailyInsight: @Sendable (DailySummary, [String]) async throws -> DailyInsight {
        get { self[DashboardClient.self].generateDailyInsight }
        set { self[DashboardClient.self] = DashboardClient(getDailySummary: self[DashboardClient.self].getDailySummary, generateDailyInsight: newValue) }
    }
}
