//
//  CustomExerciseModel.swift
//  StorageInfra
//
//  Created by SimpleCare on 2/18/26.
//

import Foundation
import SwiftData

/// 커스텀 운동 모델
@Model
public final class CustomExerciseModel {
    /// 고유 식별자
    @Attribute(.unique)
    public var id: UUID

    /// 사용자 프로필 ID
    public var userProfileId: UUID

    /// 운동 이름
    public var name: String

    /// 카테고리
    public var category: ExerciseCategory

    /// 기본 MET 값
    public var baseMET: Double

    /// SF Symbol 아이콘 이름 (선택)
    public var iconName: String?

    /// 생성 일시
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        userProfileId: UUID,
        name: String,
        category: ExerciseCategory = .other,
        baseMET: Double = 4.0,
        iconName: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userProfileId = userProfileId
        self.name = name
        self.category = category
        self.baseMET = baseMET
        self.iconName = iconName
        self.createdAt = createdAt
    }
}
