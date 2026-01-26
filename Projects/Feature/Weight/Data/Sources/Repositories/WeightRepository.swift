//
//  WeightRepository.swift
//  WeightData
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import WeightDomain
import StorageInfra

public final class WeightRepository: WeightRepositoryProtocol, @unchecked Sendable {
    private let storage: WeightRecordRepository

    public init(storage: WeightRecordRepository = WeightRecordRepository()) {
        self.storage = storage
    }

    public func getLatestWeight(userProfileId: UUID) async throws -> WeightRecord? {
        guard let model = try await storage.fetchLatestWeight(userProfileId: userProfileId) else {
            return nil
        }
        return model.toEntity()
    }

    public func getWeights(from startDate: Date, to endDate: Date, userProfileId: UUID) async throws -> [WeightRecord] {
        let models = try await storage.fetchWeights(from: startDate, to: endDate, userProfileId: userProfileId)
        return models.map { $0.toEntity() }
    }

    public func getWeights(limit: Int, userProfileId: UUID) async throws -> [WeightRecord] {
        let models = try await storage.fetchWeights(limit: limit, userProfileId: userProfileId)
        return models.map { $0.toEntity() }
    }

    public func saveWeight(_ weight: WeightRecord) async throws {
        let model = weight.toModel()
        try await storage.saveWeight(model)
    }

    public func updateWeight(_ weight: WeightRecord) async throws {
        // Fetch and update the existing model
        let models = try await storage.fetchWeights(limit: 100, userProfileId: weight.userProfileId)
        guard let existingModel = models.first(where: { $0.id == weight.id }) else {
            throw WeightRepositoryError.weightNotFound
        }
        weight.updateModel(existingModel)
        try await storage.updateWeight(existingModel)
    }

    public func deleteWeight(_ weight: WeightRecord) async throws {
        let models = try await storage.fetchWeights(limit: 100, userProfileId: weight.userProfileId)
        guard let model = models.first(where: { $0.id == weight.id }) else { return }
        try await storage.deleteWeight(model)
    }
}

public enum WeightRepositoryError: LocalizedError {
    case weightNotFound

    public var errorDescription: String? {
        switch self {
        case .weightNotFound: return "체중 기록을 찾을 수 없습니다"
        }
    }
}

// MARK: - Mapping

extension WeightRecordModel {
    func toEntity() -> WeightRecord {
        WeightRecord(
            id: id,
            userProfileId: userProfileId,
            weightKg: weightKg,
            bodyFatPercentage: bodyFatPercentage,
            skeletalMuscleMassKg: skeletalMuscleMassKg,
            date: date,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension WeightRecord {
    func toModel() -> WeightRecordModel {
        WeightRecordModel(
            id: id,
            userProfileId: userProfileId,
            weightKg: weightKg,
            bodyFatPercentage: bodyFatPercentage,
            skeletalMuscleMassKg: skeletalMuscleMassKg,
            date: date,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    func updateModel(_ model: WeightRecordModel) {
        model.weightKg = weightKg
        model.bodyFatPercentage = bodyFatPercentage
        model.skeletalMuscleMassKg = skeletalMuscleMassKg
        model.notes = notes
        model.updatedAt = Date()
    }
}
