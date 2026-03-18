//
//  WeightRepository.swift
//  WeightData
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import WeightDomain
import StorageInfra
import HealthKitInfra

public final class WeightRepository: WeightRepositoryProtocol, Sendable {
    private let storage: WeightRecordRepository
    private let healthKitManager: HealthKitManagerProtocol?

    public init(
        storage: WeightRecordRepository = WeightRecordRepository(),
        healthKitManager: HealthKitManagerProtocol? = nil
    ) {
        self.storage = storage
        self.healthKitManager = healthKitManager
    }

    public func getLatestWeight(userProfileId: UUID) async throws -> WeightRecord? {
        let localRecord = try await storage.fetchLatestWeight(userProfileId: userProfileId)?.toEntity()
        let healthKitLatest = try? await healthKitManager?.fetchLatestWeight()

        guard let hkData = healthKitLatest else {
            return localRecord
        }

        let healthKitRecord = WeightRecord(
            userProfileId: userProfileId,
            weightKg: hkData.weightKg,
            date: hkData.date
        )

        guard let local = localRecord else {
            return healthKitRecord
        }

        return local.date >= healthKitRecord.date ? local : healthKitRecord
    }

    public func getWeights(from startDate: Date, to endDate: Date, userProfileId: UUID) async throws -> [WeightRecord] {
        let models = try await storage.fetchWeights(from: startDate, to: endDate, userProfileId: userProfileId)
        var records = models.map { $0.toEntity() }

        // HealthKit 데이터 병합 (실패 시 무시)
        if let hkRecords = try? await healthKitManager?.fetchWeightRecords(from: startDate, to: endDate) {
            let localDates = Set(records.map { Calendar.current.startOfDay(for: $0.date) })
            let newRecords = hkRecords
                .filter { !localDates.contains(Calendar.current.startOfDay(for: $0.date)) }
                .map { hkData in
                    WeightRecord(
                        userProfileId: userProfileId,
                        weightKg: hkData.weightKg,
                        date: hkData.date
                    )
                }
            records.append(contentsOf: newRecords)
            records.sort { $0.date < $1.date }
        }

        return records
    }

    public func getWeights(limit: Int, userProfileId: UUID) async throws -> [WeightRecord] {
        let models = try await storage.fetchWeights(limit: limit, userProfileId: userProfileId)
        var records = models.map { $0.toEntity() }

        // HealthKit 데이터 병합 (실패 시 무시)
        if let hkRecords = try? await healthKitManager?.fetchWeightRecords(
            from: Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? .distantPast,
            to: Date()
        ) {
            let localDates = Set(records.map { Calendar.current.startOfDay(for: $0.date) })
            let newRecords = hkRecords
                .filter { !localDates.contains(Calendar.current.startOfDay(for: $0.date)) }
                .map { hkData in
                    WeightRecord(
                        userProfileId: userProfileId,
                        weightKg: hkData.weightKg,
                        date: hkData.date
                    )
                }
            records.append(contentsOf: newRecords)
            records.sort { $0.date > $1.date }
        }

        // limit 적용
        if records.count > limit {
            records = Array(records.prefix(limit))
        }

        return records
    }

    public func saveWeight(_ weight: WeightRecord) async throws {
        let model = weight.toModel()
        try await storage.saveWeight(model)

        // HealthKit에도 저장 (실패 시 무시)
        try? await healthKitManager?.saveWeight(weight.weightKg, date: weight.date)
    }

    public func updateWeight(_ weight: WeightRecord) async throws {
        // Fetch all records (no limit) to ensure we find the target regardless of record count
        let models = try await storage.fetchWeights(from: .distantPast, to: .distantFuture, userProfileId: weight.userProfileId)
        guard let existingModel = models.first(where: { $0.id == weight.id }) else {
            throw WeightRepositoryError.weightNotFound
        }
        weight.updateModel(existingModel)
        try await storage.updateWeight(existingModel)
    }

    public func deleteWeight(_ weight: WeightRecord) async throws {
        let models = try await storage.fetchWeights(from: .distantPast, to: .distantFuture, userProfileId: weight.userProfileId)
        guard let model = models.first(where: { $0.id == weight.id }) else { return }
        try await storage.deleteWeight(model)
    }
}

public enum WeightRepositoryError: LocalizedError {
    case weightNotFound

    public var errorDescription: String? {
        switch self {
        case .weightNotFound: return "error.weightNotFound".localized
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
