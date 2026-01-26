//
//  WeightRecordModel.swift
//  StorageInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import SwiftData

/// 체중 기록 모델
@Model
public final class WeightRecordModel {
    /// 고유 식별자
    @Attribute(.unique)
    public var id: UUID

    /// 사용자 프로필 ID
    public var userProfileId: UUID

    /// 체중 (kg)
    public var weightKg: Double

    /// 체지방률 (%, 선택)
    public var bodyFatPercentage: Double?

    /// 골격근량 (kg, 선택)
    public var skeletalMuscleMassKg: Double?

    /// 기록 날짜
    public var date: Date

    /// 메모
    public var notes: String?

    /// 생성 일시
    public var createdAt: Date

    /// 수정 일시
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

    /// 체중 표시 문자열
    public var weightDisplayString: String {
        String(format: "%.1f kg", weightKg)
    }

    /// 체지방률 표시 문자열
    public var bodyFatDisplayString: String? {
        guard let bodyFat = bodyFatPercentage else { return nil }
        return String(format: "%.1f%%", bodyFat)
    }
}
