//
//  WeightViewModel.swift
//  WeightPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import Combine
import WeightDomain

/// Weight ViewModel
@MainActor
public final class WeightViewModel: ObservableObject {
    @Published public private(set) var isLoading = false
    @Published public private(set) var weightTrend: WeightTrend?
    @Published public var newWeightKg: Double = 70.0
    @Published public var bodyFatPercentage: Double?
    @Published public var notes: String = ""
    @Published public private(set) var error: String?

    private let recordWeightUseCase: RecordWeightUseCaseProtocol
    private let getWeightTrendUseCase: GetWeightTrendUseCaseProtocol
    private let userProfileId: UUID
    private let currentWeight: Double
    private let targetWeight: Double

    public var onSaveComplete: (() -> Void)?

    public init(
        recordWeightUseCase: RecordWeightUseCaseProtocol,
        getWeightTrendUseCase: GetWeightTrendUseCaseProtocol,
        userProfileId: UUID,
        currentWeight: Double,
        targetWeight: Double
    ) {
        self.recordWeightUseCase = recordWeightUseCase
        self.getWeightTrendUseCase = getWeightTrendUseCase
        self.userProfileId = userProfileId
        self.currentWeight = currentWeight
        self.targetWeight = targetWeight
        self.newWeightKg = currentWeight
    }

    public func loadTrend() async {
        isLoading = true
        do {
            weightTrend = try await getWeightTrendUseCase.execute(
                userProfileId: userProfileId,
                targetWeight: targetWeight,
                limit: 30
            )
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    public func saveWeight() async {
        isLoading = true
        error = nil

        do {
            let record = WeightRecord(
                userProfileId: userProfileId,
                weightKg: newWeightKg,
                bodyFatPercentage: bodyFatPercentage,
                notes: notes.isEmpty ? nil : notes
            )
            try await recordWeightUseCase.execute(weight: record)
            await loadTrend()
            onSaveComplete?()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
