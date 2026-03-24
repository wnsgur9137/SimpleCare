//
//  WaterIntakeUseCases.swift
//  MealDomain
//

import Foundation

/// 수분 섭취 저장소 프로토콜
public protocol WaterIntakeRepositoryProtocol: Sendable {
    func recordIntake(_ intake: WaterIntake) async throws
    func getDailyIntakes(date: Date, userProfileId: UUID) async throws -> [WaterIntake]
    func deleteIntake(_ intake: WaterIntake) async throws
}

/// 수분 섭취 기록 UseCase
public protocol RecordWaterIntakeUseCaseProtocol: Sendable {
    func execute(_ intake: WaterIntake) async throws
}

public struct RecordWaterIntakeUseCase: RecordWaterIntakeUseCaseProtocol {
    private let repository: WaterIntakeRepositoryProtocol

    public init(repository: WaterIntakeRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ intake: WaterIntake) async throws {
        try await repository.recordIntake(intake)
    }
}

/// 일일 수분 섭취 조회 UseCase
public protocol GetDailyWaterIntakeUseCaseProtocol: Sendable {
    func execute(date: Date, userProfileId: UUID) async throws -> [WaterIntake]
}

public struct GetDailyWaterIntakeUseCase: GetDailyWaterIntakeUseCaseProtocol {
    private let repository: WaterIntakeRepositoryProtocol

    public init(repository: WaterIntakeRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(date: Date, userProfileId: UUID) async throws -> [WaterIntake] {
        try await repository.getDailyIntakes(date: date, userProfileId: userProfileId)
    }
}
