//
//  HealthKitManager.swift
//  HealthKitInfra
//
//  Created by SimpleCare on 2/21/26.
//

import Foundation
import HealthKit

// MARK: - HealthKitError

public enum HealthKitError: Error, LocalizedError {
    case notAvailable
    case authorizationDenied
    case dataNotFound
    case queryFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device."
        case .authorizationDenied:
            return "HealthKit authorization was denied."
        case .dataNotFound:
            return "No data found for the requested query."
        case .queryFailed(let error):
            return "HealthKit query failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - HealthKitManager

public final class HealthKitManager: @unchecked Sendable {
    public static let shared = HealthKitManager()

    private let healthStore: HKHealthStore

    // MARK: - Initialization

    private init() {
        self.healthStore = HKHealthStore()
    }

    // MARK: - Availability

    public static var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    // MARK: - Authorization

    public func requestAuthorization() async throws {
        guard Self.isAvailable else {
            throw HealthKitError.notAvailable
        }

        try await healthStore.requestAuthorization(
            toShare: HealthKitDataType.writeTypes,
            read: HealthKitDataType.readTypes
        )
    }

    public func authorizationStatus(for type: HealthKitDataType) -> HKAuthorizationStatus {
        healthStore.authorizationStatus(for: type.quantityType)
    }

    // MARK: - Step Count

    public func fetchStepCount(for date: Date) async throws -> HealthKitStepData {
        guard Self.isAvailable else {
            throw HealthKitError.notAvailable
        }

        let (startOfDay, endOfDay) = dayBounds(for: date)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )

        let steps = try await fetchStatistics(
            for: .stepCount,
            predicate: predicate
        )

        return HealthKitStepData(date: date, steps: Int(steps))
    }

    // MARK: - Active Energy

    public func fetchActiveEnergy(for date: Date) async throws -> HealthKitActivityData {
        guard Self.isAvailable else {
            throw HealthKitError.notAvailable
        }

        let (startOfDay, endOfDay) = dayBounds(for: date)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )

        let calories = try await fetchStatistics(
            for: .activeEnergy,
            predicate: predicate
        )

        return HealthKitActivityData(date: date, activeCalories: Int(calories))
    }

    // MARK: - Weight (Read)

    public func fetchWeightRecords(from startDate: Date, to endDate: Date) async throws -> [HealthKitWeightData] {
        guard Self.isAvailable else {
            throw HealthKitError.notAvailable
        }

        let dataType = HealthKitDataType.bodyMass
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: dataType.quantityType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }

                let records = (samples as? [HKQuantitySample] ?? []).map { sample in
                    HealthKitWeightData(
                        id: sample.uuid,
                        date: sample.startDate,
                        weightKg: sample.quantity.doubleValue(for: dataType.unit),
                        source: sample.sourceRevision.source.name
                    )
                }

                continuation.resume(returning: records)
            }

            healthStore.execute(query)
        }
    }

    public func fetchLatestWeight() async throws -> HealthKitWeightData? {
        guard Self.isAvailable else {
            throw HealthKitError.notAvailable
        }

        let dataType = HealthKitDataType.bodyMass
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: dataType.quantityType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }

                guard let sample = (samples as? [HKQuantitySample])?.first else {
                    continuation.resume(returning: nil)
                    return
                }

                let record = HealthKitWeightData(
                    id: sample.uuid,
                    date: sample.startDate,
                    weightKg: sample.quantity.doubleValue(for: dataType.unit),
                    source: sample.sourceRevision.source.name
                )

                continuation.resume(returning: record)
            }

            healthStore.execute(query)
        }
    }

    // MARK: - Weight (Write)

    public func saveWeight(_ weightKg: Double, date: Date) async throws {
        guard Self.isAvailable else {
            throw HealthKitError.notAvailable
        }

        let dataType = HealthKitDataType.bodyMass
        let quantity = HKQuantity(unit: dataType.unit, doubleValue: weightKg)
        let sample = HKQuantitySample(
            type: dataType.quantityType,
            quantity: quantity,
            start: date,
            end: date
        )

        try await healthStore.save(sample)
    }

    // MARK: - Private Helpers

    private func fetchStatistics(
        for type: HealthKitDataType,
        predicate: NSPredicate
    ) async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type.quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error))
                    return
                }

                let value = statistics?.sumQuantity()?.doubleValue(for: type.unit) ?? 0
                continuation.resume(returning: value)
            }

            healthStore.execute(query)
        }
    }

    private func dayBounds(for date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return (startOfDay, endOfDay)
    }
}
