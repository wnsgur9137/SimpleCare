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

public final class WeightDIContainer: DIContainer, WeightCoordinatorDependency {
    public struct Dependencies {
        public let userProfileId: UUID
        public let currentWeight: Double
        public let targetWeight: Double

        public init(userProfileId: UUID, currentWeight: Double, targetWeight: Double) {
            self.userProfileId = userProfileId
            self.currentWeight = currentWeight
            self.targetWeight = targetWeight
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

    // MARK: - Repository

    private func makeWeightRepository() -> WeightRepositoryProtocol {
        WeightRepository()
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
            }
        )
    }
}
