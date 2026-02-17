//
//  HomeFeature.swift
//  HomePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import ComposableArchitecture
import HomeDomain

@Reducer
public struct HomeFeature {
    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var viewState: ViewState = .idle
        public var dailySummary: HomeDailySummary?
        public var insight: HomeInsight = .defaultInsight
        public var selectedDate: Date = Date()
        public var userProfileId: UUID
        public var goalCalories: Int
        public var macroGoals: MacroGoals
        public var weeklyStatus: [HomeCalorieStatus?] = Array(repeating: nil, count: 7)
        public var pendingNavigation: NavigationTarget? = nil

        public enum NavigationTarget: Equatable {
            case meal
            case exercise
            case weight
        }

        public var isToday: Bool {
            Calendar.current.isDateInToday(selectedDate)
        }

        public var canGoToNextDay: Bool {
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            return tomorrow <= Date()
        }

        /// 선택된 날짜의 요일 인덱스 (0 = 월요일)
        public var selectedDayIndex: Int {
            let calendar = Calendar(identifier: .gregorian)
            let weekday = calendar.component(.weekday, from: selectedDate)
            return (weekday + 5) % 7
        }

        public enum ViewState: Equatable {
            case idle
            case loading
            case loaded
            case error(String)
        }

        public init(userProfileId: UUID, goalCalories: Int, macroGoals: MacroGoals = .default) {
            self.userProfileId = userProfileId
            self.goalCalories = goalCalories
            self.macroGoals = macroGoals
        }
    }

    // MARK: - Action

    public enum Action: Equatable {
        case onAppear
        case loadHome
        case refreshData
        case selectDate(Date)
        case goToPreviousDay
        case goToNextDay
        case selectWeekDay(Int)
        case loadHomeResponse(Result<HomeDailySummary, Error>)
        case generateInsightResponse(Result<HomeInsight, Error>)
        case loadWeeklyStatusResponse(Result<[HomeCalorieStatus?], Error>)

        // Quick Actions
        case mealButtonTapped
        case exerciseButtonTapped
        case weightButtonTapped
        case addRecordButtonTapped
        case navigationHandled

        // Delegate
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case navigateToMeal
            case navigateToExercise
            case navigateToWeight
        }

        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.onAppear, .onAppear),
                 (.loadHome, .loadHome),
                 (.refreshData, .refreshData),
                 (.goToPreviousDay, .goToPreviousDay),
                 (.goToNextDay, .goToNextDay),
                 (.mealButtonTapped, .mealButtonTapped),
                 (.exerciseButtonTapped, .exerciseButtonTapped),
                 (.weightButtonTapped, .weightButtonTapped),
                 (.addRecordButtonTapped, .addRecordButtonTapped),
                 (.navigationHandled, .navigationHandled):
                return true
            case (.selectDate(let l), .selectDate(let r)):
                return l == r
            case (.selectWeekDay(let l), .selectWeekDay(let r)):
                return l == r
            case (.loadHomeResponse(.success(let l)), .loadHomeResponse(.success(let r))):
                return l == r
            case (.loadHomeResponse(.failure), .loadHomeResponse(.failure)):
                return true
            case (.generateInsightResponse(.success(let l)), .generateInsightResponse(.success(let r))):
                return l == r
            case (.generateInsightResponse(.failure), .generateInsightResponse(.failure)):
                return true
            case (.loadWeeklyStatusResponse(.success(let l)), .loadWeeklyStatusResponse(.success(let r))):
                return l == r
            case (.loadWeeklyStatusResponse(.failure), .loadWeeklyStatusResponse(.failure)):
                return true
            case (.delegate(let l), .delegate(let r)):
                return l == r
            default:
                return false
            }
        }
    }

    // MARK: - Dependencies

    @Dependency(\.homeClient) var homeClient

    // MARK: - Reducer

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadHome)

            case .loadHome:
                state.viewState = .loading
                let date = state.selectedDate
                let userProfileId = state.userProfileId
                let goalCalories = state.goalCalories
                let macroGoals = state.macroGoals

                return .run { send in
                    do {
                        let summary = try await homeClient.getDailySummary(date, userProfileId, goalCalories, macroGoals)
                        await send(.loadHomeResponse(.success(summary)))
                    } catch {
                        await send(.loadHomeResponse(.failure(error)))
                    }
                }

            case .refreshData:
                return .send(.loadHome)

            case .selectDate(let date):
                state.selectedDate = date
                return .send(.loadHome)

            case .goToPreviousDay:
                if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: state.selectedDate) {
                    state.selectedDate = newDate
                    return .send(.loadHome)
                }
                return .none

            case .goToNextDay:
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: state.selectedDate) ?? state.selectedDate
                if tomorrow <= Date() {
                    state.selectedDate = tomorrow
                    return .send(.loadHome)
                }
                return .none

            case .selectWeekDay(let dayIndex):
                let calendar = Calendar(identifier: .gregorian)
                let today = Date()
                let currentWeekday = calendar.component(.weekday, from: today)
                let targetWeekday = ((dayIndex + 2) % 7) == 0 ? 7 : ((dayIndex + 2) % 7) + 1
                let diff = targetWeekday - currentWeekday
                if let newDate = calendar.date(byAdding: .day, value: diff, to: today),
                   newDate <= today {
                    state.selectedDate = newDate
                    return .send(.loadHome)
                }
                return .none

            case .mealButtonTapped:
                state.pendingNavigation = .meal
                return .send(.delegate(.navigateToMeal))

            case .exerciseButtonTapped:
                state.pendingNavigation = .exercise
                return .send(.delegate(.navigateToExercise))

            case .weightButtonTapped:
                state.pendingNavigation = .weight
                return .send(.delegate(.navigateToWeight))

            case .addRecordButtonTapped:
                state.pendingNavigation = .meal
                return .send(.delegate(.navigateToMeal))

            case .navigationHandled:
                state.pendingNavigation = nil
                return .none

            case .delegate:
                return .none

            case .loadHomeResponse(.success(let summary)):
                state.dailySummary = summary
                state.viewState = .loaded
                let date = state.selectedDate
                let userProfileId = state.userProfileId
                let goalCalories = state.goalCalories

                return .merge(
                    .run { send in
                        do {
                            let insight = try await homeClient.generateInsight(summary)
                            await send(.generateInsightResponse(.success(insight)))
                        } catch {
                            await send(.generateInsightResponse(.failure(error)))
                        }
                    },
                    .run { send in
                        do {
                            let statuses = try await homeClient.getWeeklyStatus(date, userProfileId, goalCalories)
                            await send(.loadWeeklyStatusResponse(.success(statuses)))
                        } catch {
                            await send(.loadWeeklyStatusResponse(.failure(error)))
                        }
                    }
                )

            case .loadHomeResponse(.failure(let error)):
                state.viewState = .error(error.localizedDescription)
                return .none

            case .generateInsightResponse(.success(let insight)):
                state.insight = insight
                return .none

            case .generateInsightResponse(.failure):
                state.insight = .defaultInsight
                return .none

            case .loadWeeklyStatusResponse(.success(let statuses)):
                state.weeklyStatus = statuses
                return .none

            case .loadWeeklyStatusResponse(.failure):
                return .none
            }
        }
    }
}

// MARK: - HomeClient

public struct HomeClient {
    public var getDailySummary: @Sendable (Date, UUID, Int, MacroGoals) async throws -> HomeDailySummary
    public var generateInsight: @Sendable (HomeDailySummary) async throws -> HomeInsight
    public var getWeeklyStatus: @Sendable (Date, UUID, Int) async throws -> [HomeCalorieStatus?]

    public init(
        getDailySummary: @escaping @Sendable (Date, UUID, Int, MacroGoals) async throws -> HomeDailySummary,
        generateInsight: @escaping @Sendable (HomeDailySummary) async throws -> HomeInsight,
        getWeeklyStatus: @escaping @Sendable (Date, UUID, Int) async throws -> [HomeCalorieStatus?]
    ) {
        self.getDailySummary = getDailySummary
        self.generateInsight = generateInsight
        self.getWeeklyStatus = getWeeklyStatus
    }
}

extension HomeClient: DependencyKey {
    public static var liveValue: HomeClient {
        HomeClient(
            getDailySummary: { _, _, goalCalories, _ in
                HomeDailySummary.empty(goalCalories: goalCalories)
            },
            generateInsight: { _ in
                .defaultInsight
            },
            getWeeklyStatus: { _, _, _ in
                Array(repeating: nil, count: 7)
            }
        )
    }

    public static var testValue: HomeClient {
        HomeClient(
            getDailySummary: { _, _, _, _ in
                HomeDailySummary(
                    date: Date(),
                    totalCalories: 1500,
                    goalCalories: 2000,
                    totalProtein: 80,
                    totalCarbs: 200,
                    totalFat: 50,
                    exerciseCalories: 200,
                    meals: [
                        HomeMealSummary(
                            mealType: .breakfast,
                            foodNames: ["토스트", "계란프라이", "우유"],
                            totalCalories: 420,
                            recordedAt: Date()
                        ),
                        HomeMealSummary(
                            mealType: .lunch,
                            foodNames: ["비빔밥"],
                            totalCalories: 650,
                            recordedAt: Date()
                        ),
                        HomeMealSummary(
                            mealType: .dinner,
                            foodNames: ["된장찌개", "밥", "김치"],
                            totalCalories: 430,
                            recordedAt: Date()
                        )
                    ],
                    exercises: [
                        HomeExerciseSummary(
                            exerciseName: "달리기",
                            duration: 30,
                            caloriesBurned: 200,
                            recordedAt: Date()
                        )
                    ],
                    streakDays: 7,
                    proteinGoal: 100,
                    carbsGoal: 250,
                    fatGoal: 70
                )
            },
            generateInsight: { _ in
                HomeInsight(comment: "단백질 섭취가 좋아요! 저녁엔 채소를 추가해보세요", emoji: "💪")
            },
            getWeeklyStatus: { _, _, _ in
                [.onTrack, .onTrack, .over, .onTrack, .under, .onTrack, nil]
            }
        )
    }
}

extension DependencyValues {
    public var homeClient: HomeClient {
        get { self[HomeClient.self] }
        set { self[HomeClient.self] = newValue }
    }
}
