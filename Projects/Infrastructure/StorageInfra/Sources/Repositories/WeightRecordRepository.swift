//
//  WeightRecordRepository.swift
//  StorageInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import SwiftData

/// 체중 기록 저장소 프로토콜
public protocol WeightRecordRepositoryProtocol: Sendable {
    func fetchLatestWeight(userProfileId: UUID) async throws -> WeightRecordModel?
    func fetchWeights(from startDate: Date, to endDate: Date, userProfileId: UUID) async throws -> [WeightRecordModel]
    func fetchWeights(limit: Int, userProfileId: UUID) async throws -> [WeightRecordModel]
    func saveWeight(_ weight: WeightRecordModel) async throws
    func updateWeight(_ weight: WeightRecordModel) async throws
    func deleteWeight(_ weight: WeightRecordModel) async throws
}

/// 체중 기록 저장소 구현
@MainActor
public final class WeightRecordRepository: WeightRecordRepositoryProtocol {
    private let container: ModelContainer

    nonisolated public init(container: ModelContainer = StorageContainer.shared.container) {
        self.container = container
    }

    public func fetchLatestWeight(userProfileId: UUID) async throws -> WeightRecordModel? {
        let context = container.mainContext
        let predicate = #Predicate<WeightRecordModel> { weight in
            weight.userProfileId == userProfileId
        }
        var descriptor = FetchDescriptor<WeightRecordModel>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
        descriptor.fetchLimit = 1

        let weights = try context.fetch(descriptor)
        return weights.first
    }

    public func fetchWeights(from startDate: Date, to endDate: Date, userProfileId: UUID) async throws -> [WeightRecordModel] {
        let context = container.mainContext
        let predicate = #Predicate<WeightRecordModel> { weight in
            weight.userProfileId == userProfileId &&
            weight.date >= startDate &&
            weight.date < endDate
        }
        var descriptor = FetchDescriptor<WeightRecordModel>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.date, order: .forward)]

        return try context.fetch(descriptor)
    }

    public func fetchWeights(limit: Int, userProfileId: UUID) async throws -> [WeightRecordModel] {
        let context = container.mainContext
        let predicate = #Predicate<WeightRecordModel> { weight in
            weight.userProfileId == userProfileId
        }
        var descriptor = FetchDescriptor<WeightRecordModel>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
        descriptor.fetchLimit = limit

        return try context.fetch(descriptor)
    }

    public func saveWeight(_ weight: WeightRecordModel) async throws {
        let context = container.mainContext
        context.insert(weight)
        try context.save()
    }

    public func updateWeight(_ weight: WeightRecordModel) async throws {
        let context = container.mainContext
        weight.updatedAt = Date()
        try context.save()
    }

    public func deleteWeight(_ weight: WeightRecordModel) async throws {
        let context = container.mainContext
        context.delete(weight)
        try context.save()
    }
}
