//
//  WaterIntakeModel.swift
//  StorageInfra
//

import Foundation
import SwiftData

/// 수분 섭취 기록 모델
@Model
public final class WaterIntakeModel {
    /// 고유 식별자
    @Attribute(.unique)
    public var id: UUID

    /// 사용자 프로필 ID
    public var userProfileId: UUID

    /// 섭취량 (ml)
    public var amountMl: Int

    /// 기록 날짜
    public var date: Date

    /// 생성 일시
    public var createdAt: Date

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
