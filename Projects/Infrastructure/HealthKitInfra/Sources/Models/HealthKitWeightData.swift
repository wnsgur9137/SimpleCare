//
//  HealthKitWeightData.swift
//  HealthKitInfra
//
//  Created by SimpleCare on 2/21/26.
//

import Foundation

public struct HealthKitWeightData: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let date: Date
    public let weightKg: Double
    public let source: String

    public init(id: UUID = UUID(), date: Date, weightKg: Double, source: String) {
        self.id = id
        self.date = date
        self.weightKg = weightKg
        self.source = source
    }
}
