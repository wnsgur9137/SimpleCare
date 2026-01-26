//
//  WeightUseCases.swift
//  WeightDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// 체중 기록 UseCase
public protocol RecordWeightUseCaseProtocol: Sendable {
    func execute(weight: WeightRecord) async throws
}

public struct RecordWeightUseCase: RecordWeightUseCaseProtocol {
    private let repository: WeightRepositoryProtocol

    public init(repository: WeightRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(weight: WeightRecord) async throws {
        try await repository.saveWeight(weight)
    }
}

/// 체중 추세 조회 UseCase
public protocol GetWeightTrendUseCaseProtocol: Sendable {
    func execute(userProfileId: UUID, targetWeight: Double, limit: Int) async throws -> WeightTrend
}

public struct GetWeightTrendUseCase: GetWeightTrendUseCaseProtocol {
    private let repository: WeightRepositoryProtocol

    public init(repository: WeightRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(userProfileId: UUID, targetWeight: Double, limit: Int) async throws -> WeightTrend {
        let records = try await repository.getWeights(limit: limit, userProfileId: userProfileId)
        let currentWeight = records.first?.weightKg ?? targetWeight
        let previousWeight = records.count > 1 ? records[1].weightKg : nil

        // 주간/월간 변화 계산
        var weeklyChange: Double? = nil
        var monthlyChange: Double? = nil

        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!

        if let weekOldRecord = records.first(where: { $0.date <= oneWeekAgo }) {
            weeklyChange = currentWeight - weekOldRecord.weightKg
        }

        if let monthOldRecord = records.first(where: { $0.date <= oneMonthAgo }) {
            monthlyChange = currentWeight - monthOldRecord.weightKg
        }

        return WeightTrend(
            currentWeight: currentWeight,
            previousWeight: previousWeight,
            targetWeight: targetWeight,
            weeklyChange: weeklyChange,
            monthlyChange: monthlyChange,
            records: records
        )
    }
}

/// Weight Repository 프로토콜
public protocol WeightRepositoryProtocol: Sendable {
    func getLatestWeight(userProfileId: UUID) async throws -> WeightRecord?
    func getWeights(from startDate: Date, to endDate: Date, userProfileId: UUID) async throws -> [WeightRecord]
    func getWeights(limit: Int, userProfileId: UUID) async throws -> [WeightRecord]
    func saveWeight(_ weight: WeightRecord) async throws
    func updateWeight(_ weight: WeightRecord) async throws
    func deleteWeight(_ weight: WeightRecord) async throws
}
