//
//  HealthKitDataType.swift
//  HealthKitInfra
//
//  Created by SimpleCare on 2/21/26.
//

import Foundation
import HealthKit

// MARK: - HealthKitDataType

public enum HealthKitDataType: CaseIterable, Sendable {
    case stepCount
    case activeEnergy
    case bodyMass

    public var quantityType: HKQuantityType {
        switch self {
        case .stepCount:
            return HKQuantityType(.stepCount)
        case .activeEnergy:
            return HKQuantityType(.activeEnergyBurned)
        case .bodyMass:
            return HKQuantityType(.bodyMass)
        }
    }

    public var unit: HKUnit {
        switch self {
        case .stepCount:
            return .count()
        case .activeEnergy:
            return .kilocalorie()
        case .bodyMass:
            return .gramUnit(with: .kilo)
        }
    }

    // MARK: - Authorization Type Sets

    public static var readTypes: Set<HKObjectType> {
        Set(allCases.map { $0.quantityType })
    }

    public static var writeTypes: Set<HKSampleType> {
        Set([HealthKitDataType.bodyMass.quantityType])
    }
}
