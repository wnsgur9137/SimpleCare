//
//  WaterIntakeDataRepository.swift
//  MealData
//

import Foundation
import MealDomain
import StorageInfra

public final class WaterIntakeDataRepository: WaterIntakeRepositoryProtocol, Sendable {
    private let storage: WaterIntakeRepository

    public init(storage: WaterIntakeRepository = WaterIntakeRepository()) {
        self.storage = storage
    }

    public func recordIntake(_ intake: WaterIntake) async throws {
        let model = WaterIntakeModel(
            id: intake.id,
            userProfileId: intake.userProfileId,
            amountMl: intake.amountMl,
            date: intake.date,
            createdAt: intake.createdAt
        )
        try await storage.recordIntake(model)
    }

    public func getDailyIntakes(date: Date, userProfileId: UUID) async throws -> [WaterIntake] {
        let models = try await storage.fetchDailyIntakes(date: date, userProfileId: userProfileId)
        return models.map { model in
            WaterIntake(
                id: model.id,
                userProfileId: model.userProfileId,
                amountMl: model.amountMl,
                date: model.date,
                createdAt: model.createdAt
            )
        }
    }

    public func deleteIntake(_ intake: WaterIntake) async throws {
        let intakes = try await storage.fetchDailyIntakes(date: intake.date, userProfileId: intake.userProfileId)
        guard let model = intakes.first(where: { $0.id == intake.id }) else { return }
        try await storage.deleteIntake(model)
    }
}
