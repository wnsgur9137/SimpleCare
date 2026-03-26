//
//  WaterIntakeRepository.swift
//  StorageInfra
//

import Foundation
import SwiftData

/// 수분 섭취 저장소 프로토콜
public protocol WaterIntakeStorageProtocol: Sendable {
    func recordIntake(_ model: WaterIntakeModel) async throws
    func fetchDailyIntakes(date: Date, userProfileId: UUID) async throws -> [WaterIntakeModel]
    func deleteIntake(_ model: WaterIntakeModel) async throws
}

/// 수분 섭취 저장소 구현
@MainActor
public final class WaterIntakeRepository: WaterIntakeStorageProtocol {
    private let container: ModelContainer

    nonisolated public init(container: ModelContainer = StorageContainer.shared.container) {
        self.container = container
    }

    public func recordIntake(_ model: WaterIntakeModel) async throws {
        let context = container.mainContext
        context.insert(model)
        try context.save()
    }

    public func fetchDailyIntakes(date: Date, userProfileId: UUID) async throws -> [WaterIntakeModel] {
        let context = container.mainContext
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

        let predicate = #Predicate<WaterIntakeModel> { intake in
            intake.userProfileId == userProfileId &&
            intake.date >= startOfDay &&
            intake.date < endOfDay
        }
        var descriptor = FetchDescriptor<WaterIntakeModel>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.createdAt, order: .forward)]

        return try context.fetch(descriptor)
    }

    public func deleteIntake(_ model: WaterIntakeModel) async throws {
        let context = container.mainContext
        context.delete(model)
        try context.save()
    }
}
