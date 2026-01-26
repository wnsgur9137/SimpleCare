//
//  DashboardViewModel.swift
//  DashboardPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import Combine
import DashboardDomain

/// Dashboard 화면 상태
public enum DashboardViewState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

/// Dashboard ViewModel
@MainActor
public final class DashboardViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public private(set) var state: DashboardViewState = .idle
    @Published public private(set) var dailySummary: DailySummary?
    @Published public private(set) var insight: DailyInsight = .defaultInsight
    @Published public var selectedDate: Date = Date()

    // MARK: - Dependencies

    private let getDailySummaryUseCase: GetDailySummaryUseCaseProtocol
    private let generateInsightUseCase: GenerateDailyInsightUseCaseProtocol
    private let userProfileId: UUID
    private let goalCalories: Int

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(
        getDailySummaryUseCase: GetDailySummaryUseCaseProtocol,
        generateInsightUseCase: GenerateDailyInsightUseCaseProtocol,
        userProfileId: UUID,
        goalCalories: Int
    ) {
        self.getDailySummaryUseCase = getDailySummaryUseCase
        self.generateInsightUseCase = generateInsightUseCase
        self.userProfileId = userProfileId
        self.goalCalories = goalCalories

        setupBindings()
    }

    // MARK: - Public Methods

    public func loadDashboard() async {
        state = .loading

        do {
            let summary = try await getDailySummaryUseCase.execute(
                date: selectedDate,
                userProfileId: userProfileId,
                goalCalories: goalCalories
            )
            dailySummary = summary
            state = .loaded

            // AI 인사이트 생성 (백그라운드)
            await generateInsight(for: summary)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    public func refreshData() async {
        await loadDashboard()
    }

    public func selectDate(_ date: Date) {
        selectedDate = date
        Task {
            await loadDashboard()
        }
    }

    public func goToPreviousDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectDate(newDate)
        }
    }

    public func goToNextDay() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        if tomorrow <= Date() {
            selectDate(tomorrow)
        }
    }

    public var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    public var canGoToNextDay: Bool {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        return tomorrow <= Date()
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // 날짜 변경 시 자동 로드
        $selectedDate
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.loadDashboard()
                }
            }
            .store(in: &cancellables)
    }

    private func generateInsight(for summary: DailySummary) async {
        do {
            let mealNames: [String] = [] // TODO: Get actual meal names
            let generatedInsight = try await generateInsightUseCase.execute(
                summary: summary,
                mealNames: mealNames
            )
            insight = generatedInsight
        } catch {
            // 인사이트 생성 실패 시 기본값 사용
            insight = .defaultInsight
        }
    }
}
