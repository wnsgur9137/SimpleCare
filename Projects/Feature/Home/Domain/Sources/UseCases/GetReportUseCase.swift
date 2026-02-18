//
//  GetReportUseCase.swift
//  HomeDomain
//
//  Created by SimpleCare on 2/18/26.
//

import Foundation

/// 리포트 저장소 프로토콜
public protocol HomeReportRepositoryProtocol: Sendable {
    func getWeeklyReport(baseDate: Date, userProfileId: UUID, goalCalories: Int) async throws -> WeeklyReport
    func getMonthlyReport(baseDate: Date, userProfileId: UUID, goalCalories: Int) async throws -> MonthlyReport
}

/// 주간 리포트 조회 UseCase
public protocol GetWeeklyReportUseCaseProtocol: Sendable {
    func execute(baseDate: Date, userProfileId: UUID, goalCalories: Int) async throws -> WeeklyReport
}

public struct GetWeeklyReportUseCase: GetWeeklyReportUseCaseProtocol {
    private let repository: HomeReportRepositoryProtocol

    public init(repository: HomeReportRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(baseDate: Date, userProfileId: UUID, goalCalories: Int) async throws -> WeeklyReport {
        try await repository.getWeeklyReport(baseDate: baseDate, userProfileId: userProfileId, goalCalories: goalCalories)
    }
}

/// 월간 리포트 조회 UseCase
public protocol GetMonthlyReportUseCaseProtocol: Sendable {
    func execute(baseDate: Date, userProfileId: UUID, goalCalories: Int) async throws -> MonthlyReport
}

public struct GetMonthlyReportUseCase: GetMonthlyReportUseCaseProtocol {
    private let repository: HomeReportRepositoryProtocol

    public init(repository: HomeReportRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(baseDate: Date, userProfileId: UUID, goalCalories: Int) async throws -> MonthlyReport {
        try await repository.getMonthlyReport(baseDate: baseDate, userProfileId: userProfileId, goalCalories: goalCalories)
    }
}
