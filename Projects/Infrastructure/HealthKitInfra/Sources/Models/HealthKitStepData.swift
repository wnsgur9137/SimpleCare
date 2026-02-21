//
//  HealthKitStepData.swift
//  HealthKitInfra
//
//  Created by SimpleCare on 2/21/26.
//

import Foundation

public struct HealthKitStepData: Equatable, Sendable {
    public let date: Date
    public let steps: Int

    public init(date: Date, steps: Int) {
        self.date = date
        self.steps = steps
    }

    public static let empty = HealthKitStepData(date: Date(), steps: 0)
}
