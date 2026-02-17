//
//  GetDailySummaryUseCase.swift
//  HomeDomain
//
//  Created by SimpleCare on 2/15/26.
//

import Foundation

/// 영양소 목표
public struct MacroGoals: Equatable, Sendable {
    public let proteinGoal: Double
    public let carbsGoal: Double
    public let fatGoal: Double

    public init(proteinGoal: Double, carbsGoal: Double, fatGoal: Double) {
        self.proteinGoal = proteinGoal
        self.carbsGoal = carbsGoal
        self.fatGoal = fatGoal
    }

    public static let `default` = MacroGoals(proteinGoal: 100, carbsGoal: 250, fatGoal: 70)
}

/// 홈 일일 요약 저장소 프로토콜 (Data layer에서 구현)
public protocol HomeDailySummaryRepositoryProtocol: Sendable {
    func getDailySummary(date: Date, userProfileId: UUID, goalCalories: Int, macroGoals: MacroGoals) async throws -> HomeDailySummary
    func getWeeklyStatus(baseDate: Date, userProfileId: UUID, goalCalories: Int) async throws -> [HomeCalorieStatus?]
}

/// 일일 요약 조회 UseCase 프로토콜
public protocol GetDailySummaryUseCaseProtocol: Sendable {
    func execute(date: Date, userProfileId: UUID, goalCalories: Int, macroGoals: MacroGoals) async throws -> HomeDailySummary
}

/// 일일 요약 조회 UseCase 구현
public struct GetDailySummaryUseCase: GetDailySummaryUseCaseProtocol {
    private let repository: HomeDailySummaryRepositoryProtocol

    public init(repository: HomeDailySummaryRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(date: Date, userProfileId: UUID, goalCalories: Int, macroGoals: MacroGoals) async throws -> HomeDailySummary {
        try await repository.getDailySummary(date: date, userProfileId: userProfileId, goalCalories: goalCalories, macroGoals: macroGoals)
    }
}
