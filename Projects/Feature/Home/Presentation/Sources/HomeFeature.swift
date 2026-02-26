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
        public var showReport: Bool = false
        public var reportType: ReportType = .weekly
        public var weeklyReport: WeeklyReport?
        public var monthlyReport: MonthlyReport?
        public var isLoadingReport: Bool = false
        public var isHealthKitAvailable: Bool = false
        public var isHealthKitAuthorized: Bool = false

        public enum NavigationTarget: Equatable {
            case meal
            case mealDetail(UUID)
            case exercise
            case exerciseDetail(UUID)
            case weight
            case settings
            case profile
        }

        public enum ReportType: String, Equatable, CaseIterable {
            case weekly = "주간"
            case monthly = "월간"
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

        // Report
        case reportButtonTapped
        case dismissReport
        case selectReportType(State.ReportType)
        case loadWeeklyReport
        case loadMonthlyReport
        case loadWeeklyReportResponse(Result<WeeklyReport, Error>)
        case loadMonthlyReportResponse(Result<MonthlyReport, Error>)

        // HealthKit
        case healthKitAuthStatusChanged(Bool)
        case openHealthSettingsTapped

        // Quick Actions
        case mealButtonTapped
        case mealDetailTapped(UUID)
        case exerciseButtonTapped
        case exerciseDetailTapped(UUID)
        case weightButtonTapped
        case addRecordButtonTapped
        case settingsButtonTapped
        case profileButtonTapped
        case navigationHandled

        // Delegate
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case navigateToMeal
            case navigateToMealDetail(UUID)
            case navigateToExercise
            case navigateToExerciseDetail(UUID)
            case navigateToWeight
            case navigateToSettings
            case navigateToProfile
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
                 (.settingsButtonTapped, .settingsButtonTapped),
                 (.profileButtonTapped, .profileButtonTapped),
                 (.navigationHandled, .navigationHandled),
                 (.reportButtonTapped, .reportButtonTapped),
                 (.dismissReport, .dismissReport),
                 (.loadWeeklyReport, .loadWeeklyReport),
                 (.loadMonthlyReport, .loadMonthlyReport),
                 (.openHealthSettingsTapped, .openHealthSettingsTapped):
                return true
            case (.mealDetailTapped(let l), .mealDetailTapped(let r)):
                return l == r
            case (.exerciseDetailTapped(let l), .exerciseDetailTapped(let r)):
                return l == r
            case (.healthKitAuthStatusChanged(let l), .healthKitAuthStatusChanged(let r)):
                return l == r
            case (.selectDate(let l), .selectDate(let r)):
                return l == r
            case (.selectWeekDay(let l), .selectWeekDay(let r)):
                return l == r
            case (.selectReportType(let l), .selectReportType(let r)):
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
            case (.loadWeeklyReportResponse(.success(let l)), .loadWeeklyReportResponse(.success(let r))):
                return l == r
            case (.loadWeeklyReportResponse(.failure), .loadWeeklyReportResponse(.failure)):
                return true
            case (.loadMonthlyReportResponse(.success(let l)), .loadMonthlyReportResponse(.success(let r))):
                return l == r
            case (.loadMonthlyReportResponse(.failure), .loadMonthlyReportResponse(.failure)):
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
                state.isHealthKitAvailable = homeClient.isHealthKitAvailable()
                return .merge(
                    .send(.loadHome),
                    .run { [homeClient] send in
                        await homeClient.requestHealthKitAuth()
                        let isAuthorized = homeClient.checkHealthKitAuthStatus()
                        await send(.healthKitAuthStatusChanged(isAuthorized))
                    }
                )

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
                return .merge(
                    .send(.loadHome),
                    .run { [homeClient] send in
                        let isAuthorized = homeClient.checkHealthKitAuthStatus()
                        await send(.healthKitAuthStatusChanged(isAuthorized))
                    }
                )

            case .healthKitAuthStatusChanged(let isAuthorized):
                state.isHealthKitAuthorized = isAuthorized
                return .none

            case .openHealthSettingsTapped:
                return .run { [homeClient] _ in
                    await homeClient.openHealthSettings()
                }

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

            case .mealDetailTapped(let mealId):
                state.pendingNavigation = .mealDetail(mealId)
                return .send(.delegate(.navigateToMealDetail(mealId)))

            case .exerciseButtonTapped:
                state.pendingNavigation = .exercise
                return .send(.delegate(.navigateToExercise))

            case .exerciseDetailTapped(let exerciseId):
                state.pendingNavigation = .exerciseDetail(exerciseId)
                return .send(.delegate(.navigateToExerciseDetail(exerciseId)))

            case .weightButtonTapped:
                state.pendingNavigation = .weight
                return .send(.delegate(.navigateToWeight))

            case .addRecordButtonTapped:
                state.pendingNavigation = .meal
                return .send(.delegate(.navigateToMeal))

            case .settingsButtonTapped:
                state.pendingNavigation = .settings
                return .send(.delegate(.navigateToSettings))

            case .profileButtonTapped:
                state.pendingNavigation = .profile
                return .send(.delegate(.navigateToProfile))

            case .navigationHandled:
                state.pendingNavigation = nil
                return .none

            case .reportButtonTapped:
                state.showReport = true
                state.isLoadingReport = true
                return .send(.loadWeeklyReport)

            case .dismissReport:
                state.showReport = false
                state.weeklyReport = nil
                state.monthlyReport = nil
                return .none

            case .selectReportType(let type):
                state.reportType = type
                state.isLoadingReport = true
                switch type {
                case .weekly:
                    return .send(.loadWeeklyReport)
                case .monthly:
                    return .send(.loadMonthlyReport)
                }

            case .loadWeeklyReport:
                let date = state.selectedDate
                let userProfileId = state.userProfileId
                let goalCalories = state.goalCalories
                return .run { send in
                    do {
                        let report = try await homeClient.getWeeklyReport(date, userProfileId, goalCalories)
                        await send(.loadWeeklyReportResponse(.success(report)))
                    } catch {
                        await send(.loadWeeklyReportResponse(.failure(error)))
                    }
                }

            case .loadMonthlyReport:
                let date = state.selectedDate
                let userProfileId = state.userProfileId
                let goalCalories = state.goalCalories
                return .run { send in
                    do {
                        let report = try await homeClient.getMonthlyReport(date, userProfileId, goalCalories)
                        await send(.loadMonthlyReportResponse(.success(report)))
                    } catch {
                        await send(.loadMonthlyReportResponse(.failure(error)))
                    }
                }

            case .loadWeeklyReportResponse(.success(let report)):
                state.weeklyReport = report
                state.isLoadingReport = false
                return .none

            case .loadWeeklyReportResponse(.failure(let error)):
                state.isLoadingReport = false
                state.viewState = .error(error.localizedDescription)
                return .none

            case .loadMonthlyReportResponse(.success(let report)):
                state.monthlyReport = report
                state.isLoadingReport = false
                return .none

            case .loadMonthlyReportResponse(.failure(let error)):
                state.isLoadingReport = false
                state.viewState = .error(error.localizedDescription)
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
    public var getWeeklyReport: @Sendable (Date, UUID, Int) async throws -> WeeklyReport
    public var getMonthlyReport: @Sendable (Date, UUID, Int) async throws -> MonthlyReport
    public var requestHealthKitAuth: @Sendable () async -> Void
    public var isHealthKitAvailable: @Sendable () -> Bool
    public var checkHealthKitAuthStatus: @Sendable () -> Bool
    public var openHealthSettings: @Sendable () async -> Void

    public init(
        getDailySummary: @escaping @Sendable (Date, UUID, Int, MacroGoals) async throws -> HomeDailySummary,
        generateInsight: @escaping @Sendable (HomeDailySummary) async throws -> HomeInsight,
        getWeeklyStatus: @escaping @Sendable (Date, UUID, Int) async throws -> [HomeCalorieStatus?],
        getWeeklyReport: @escaping @Sendable (Date, UUID, Int) async throws -> WeeklyReport,
        getMonthlyReport: @escaping @Sendable (Date, UUID, Int) async throws -> MonthlyReport,
        requestHealthKitAuth: @escaping @Sendable () async -> Void,
        isHealthKitAvailable: @escaping @Sendable () -> Bool,
        checkHealthKitAuthStatus: @escaping @Sendable () -> Bool,
        openHealthSettings: @escaping @Sendable () async -> Void
    ) {
        self.getDailySummary = getDailySummary
        self.generateInsight = generateInsight
        self.getWeeklyStatus = getWeeklyStatus
        self.getWeeklyReport = getWeeklyReport
        self.getMonthlyReport = getMonthlyReport
        self.requestHealthKitAuth = requestHealthKitAuth
        self.isHealthKitAvailable = isHealthKitAvailable
        self.checkHealthKitAuthStatus = checkHealthKitAuthStatus
        self.openHealthSettings = openHealthSettings
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
            },
            getWeeklyReport: { _, _, goalCalories in
                WeeklyReport(
                    weekStartDate: Date(),
                    avgDailyCalories: 0,
                    totalExerciseMinutes: 0,
                    totalExerciseCalories: 0,
                    weightChange: nil,
                    streakDays: 0,
                    dailyCalories: Array(repeating: 0, count: 7),
                    goalCalories: goalCalories
                )
            },
            getMonthlyReport: { _, _, goalCalories in
                MonthlyReport(
                    monthDate: Date(),
                    avgDailyCalories: 0,
                    totalExerciseMinutes: 0,
                    weightChange: nil,
                    weeklyCalorieTrend: [],
                    macroAverage: MacroAverage(protein: 0, carbs: 0, fat: 0),
                    goalCalories: goalCalories
                )
            },
            requestHealthKitAuth: {},
            isHealthKitAvailable: { false },
            checkHealthKitAuthStatus: { false },
            openHealthSettings: {}
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
                    fatGoal: 70,
                    steps: 8500,
                    activeCalories: 320
                )
            },
            generateInsight: { _ in
                HomeInsight(comment: "단백질 섭취가 좋아요! 저녁엔 채소를 추가해보세요", emoji: "💪")
            },
            getWeeklyStatus: { _, _, _ in
                [.onTrack, .onTrack, .over, .onTrack, .under, .onTrack, nil]
            },
            getWeeklyReport: { _, _, _ in
                WeeklyReport(
                    weekStartDate: Date(),
                    avgDailyCalories: 1800,
                    totalExerciseMinutes: 150,
                    totalExerciseCalories: 600,
                    weightChange: -0.3,
                    streakDays: 5,
                    dailyCalories: [1900, 2100, 1700, 1850, 2000, 1600, 1950],
                    goalCalories: 2000,
                    topExercises: [
                        ExerciseStat(name: "달리기", count: 3),
                        ExerciseStat(name: "웨이트 트레이닝", count: 2)
                    ]
                )
            },
            getMonthlyReport: { _, _, _ in
                MonthlyReport(
                    monthDate: Date(),
                    avgDailyCalories: 1850,
                    totalExerciseMinutes: 600,
                    weightChange: -1.2,
                    weeklyCalorieTrend: [1900, 1850, 1800, 1750],
                    macroAverage: MacroAverage(protein: 80, carbs: 220, fat: 55),
                    goalCalories: 2000,
                    recordedDays: 25
                )
            },
            requestHealthKitAuth: {},
            isHealthKitAvailable: { true },
            checkHealthKitAuthStatus: { true },
            openHealthSettings: {}
        )
    }
}

extension DependencyValues {
    public var homeClient: HomeClient {
        get { self[HomeClient.self] }
        set { self[HomeClient.self] = newValue }
    }
}
