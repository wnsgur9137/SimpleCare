//
//  WeightRecord.swift
//  WeightDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// 체중 기록 엔티티
public struct WeightRecord: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let userProfileId: UUID
    public var weightKg: Double
    public var bodyFatPercentage: Double?
    public var skeletalMuscleMassKg: Double?
    public var date: Date
    public var notes: String?
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        userProfileId: UUID,
        weightKg: Double,
        bodyFatPercentage: Double? = nil,
        skeletalMuscleMassKg: Double? = nil,
        date: Date = Date(),
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userProfileId = userProfileId
        self.weightKg = weightKg
        self.bodyFatPercentage = bodyFatPercentage
        self.skeletalMuscleMassKg = skeletalMuscleMassKg
        self.date = date
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public var weightDisplayString: String {
        String(format: "%.1f kg", weightKg)
    }

    public var bodyFatDisplayString: String? {
        guard let bodyFat = bodyFatPercentage else { return nil }
        return String(format: "%.1f%%", bodyFat)
    }
}

/// 체중 추세 정보
public struct WeightTrend: Equatable, Sendable {
    public let currentWeight: Double
    public let previousWeight: Double?
    public let targetWeight: Double
    public let weeklyChange: Double?
    public let monthlyChange: Double?
    public let records: [WeightRecord]

    public init(
        currentWeight: Double,
        previousWeight: Double? = nil,
        targetWeight: Double,
        weeklyChange: Double? = nil,
        monthlyChange: Double? = nil,
        records: [WeightRecord] = []
    ) {
        self.currentWeight = currentWeight
        self.previousWeight = previousWeight
        self.targetWeight = targetWeight
        self.weeklyChange = weeklyChange
        self.monthlyChange = monthlyChange
        self.records = records
    }

    /// 목표까지 남은 체중
    public var remainingToGoal: Double {
        currentWeight - targetWeight
    }

    /// 목표 달성률 (시작 체중 기준)
    public func progressToGoal(from startWeight: Double) -> Double {
        let totalToLose = startWeight - targetWeight
        let currentlyLost = startWeight - currentWeight
        guard totalToLose != 0 else { return 1.0 }
        return currentlyLost / totalToLose
    }
}
