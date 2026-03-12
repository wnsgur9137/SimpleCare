//
//  WeightDIContainer.swift
//  Weight
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import BasePresentation
import WeightDomain
import WeightData
import WeightPresentation
import HealthKitInfra

public final class WeightDIContainer: DIContainer, WeightCoordinatorDependency {
    public struct Dependencies {
        public let userProfileId: UUID
        public let currentWeight: Double
        public let targetWeight: Double
        public let heightCm: Double

        public init(userProfileId: UUID, currentWeight: Double, targetWeight: Double, heightCm: Double = 170.0) {
            self.userProfileId = userProfileId
            self.currentWeight = currentWeight
            self.targetWeight = targetWeight
            self.heightCm = heightCm
        }
    }

    public let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - WeightCoordinatorDependency

    public var userProfileId: UUID {
        dependencies.userProfileId
    }

    public var currentWeight: Double {
        dependencies.currentWeight
    }

    public var targetWeight: Double {
        dependencies.targetWeight
    }

    public var heightCm: Double {
        dependencies.heightCm
    }

    // MARK: - Repository

    private func makeWeightRepository() -> WeightRepositoryProtocol {
        WeightRepository(
            healthKitManager: HealthKitManager.isAvailable ? HealthKitManager.shared : nil
        )
    }

    // MARK: - Use Cases

    private func makeRecordWeightUseCase() -> RecordWeightUseCaseProtocol {
        RecordWeightUseCase(repository: makeWeightRepository())
    }

    private func makeGetWeightTrendUseCase() -> GetWeightTrendUseCaseProtocol {
        GetWeightTrendUseCase(repository: makeWeightRepository())
    }

    // MARK: - TCA Dependencies

    public var weightClient: WeightClient {
        let recordUseCase = makeRecordWeightUseCase()
        let trendUseCase = makeGetWeightTrendUseCase()
        let healthKitManager = HealthKitManager.shared

        return WeightClient(
            recordWeight: { record in
                try await recordUseCase.execute(weight: record)
            },
            getWeightTrend: { userProfileId, targetWeight, limit in
                try await trendUseCase.execute(
                    userProfileId: userProfileId,
                    targetWeight: targetWeight,
                    limit: limit
                )
            },
            syncWeightToHealthKit: { weightKg, date in
                guard HealthKitManager.isAvailable else { return }
                try? await healthKitManager.saveWeight(weightKg, date: date)
            },
            isHealthKitAvailable: {
                HealthKitManager.isAvailable
            }
        )
    }
}
