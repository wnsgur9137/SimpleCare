//
//  CustomExercise.swift
//  ExerciseDomain
//
//  Created by SimpleCare on 2/18/26.
//

import Foundation

/// 커스텀 운동 도메인 엔티티
public struct CustomExercise: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let userProfileId: UUID
    public var name: String
    public var category: ExerciseCategory
    public var baseMET: Double
    public var iconName: String?

    public init(
        id: UUID = UUID(),
        userProfileId: UUID,
        name: String,
        category: ExerciseCategory = .other,
        baseMET: Double = 4.0,
        iconName: String? = nil
    ) {
        self.id = id
        self.userProfileId = userProfileId
        self.name = name
        self.category = category
        self.baseMET = baseMET
        self.iconName = iconName
    }
}
