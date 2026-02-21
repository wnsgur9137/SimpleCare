//
//  HealthKitActivityData.swift
//  HealthKitInfra
//
//  Created by SimpleCare on 2/21/26.
//

import Foundation

public struct HealthKitActivityData: Equatable, Sendable {
    public let date: Date
    public let activeCalories: Int

    public init(date: Date, activeCalories: Int) {
        self.date = date
        self.activeCalories = activeCalories
    }

    public static let empty = HealthKitActivityData(date: Date(), activeCalories: 0)
}
