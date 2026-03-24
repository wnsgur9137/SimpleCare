//
//  WaterIntake.swift
//  MealDomain
//

import Foundation

/// 수분 섭취 기록 엔티티
public struct WaterIntake: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let userProfileId: UUID
    public var amountMl: Int
    public var date: Date
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        userProfileId: UUID,
        amountMl: Int,
        date: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userProfileId = userProfileId
        self.amountMl = amountMl
        self.date = date
        self.createdAt = createdAt
    }
}
