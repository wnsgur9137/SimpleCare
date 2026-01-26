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

public final class WeightDIContainer: DIContainer, @MainActor WeightCoordinatorDependency {
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

    private func makeWeightRepository() -> WeightRepositoryProtocol {
        WeightRepository()
    }

    private func makeRecordWeightUseCase() -> RecordWeightUseCaseProtocol {
        RecordWeightUseCase(repository: makeWeightRepository())
    }

    private func makeGetWeightTrendUseCase() -> GetWeightTrendUseCaseProtocol {
        GetWeightTrendUseCase(repository: makeWeightRepository())
    }

    @MainActor
    public func makeWeightViewModel() -> WeightViewModel {
        WeightViewModel(
            recordWeightUseCase: makeRecordWeightUseCase(),
            getWeightTrendUseCase: makeGetWeightTrendUseCase(),
            userProfileId: dependencies.userProfileId,
            currentWeight: dependencies.currentWeight,
            targetWeight: dependencies.targetWeight
        )
    }
}
