//
//  GenerateDailyInsightUseCase.swift
//  HomeDomain
//
//  Created by SimpleCare on 2/15/26.
//

import Foundation

/// 홈 인사이트 서비스 프로토콜 (Data layer에서 구현)
public protocol HomeInsightServiceProtocol: Sendable {
    func generateInsight(from summary: HomeDailySummary) async throws -> HomeInsight
}

/// 일일 인사이트 생성 UseCase 프로토콜
public protocol GenerateDailyInsightUseCaseProtocol: Sendable {
    func execute(summary: HomeDailySummary) async throws -> HomeInsight
}

/// 일일 인사이트 생성 UseCase 구현
public struct GenerateDailyInsightUseCase: GenerateDailyInsightUseCaseProtocol {
    private let insightService: HomeInsightServiceProtocol

    public init(insightService: HomeInsightServiceProtocol) {
        self.insightService = insightService
    }

    public func execute(summary: HomeDailySummary) async throws -> HomeInsight {
        try await insightService.generateInsight(from: summary)
    }
}
