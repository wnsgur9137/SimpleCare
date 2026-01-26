//
//  HomeExerciseSummary.swift
//  HomeDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// 운동 요약 정보
public struct HomeExerciseSummary: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let exerciseName: String
    public let duration: Int  // minutes
    public let caloriesBurned: Int
    public let recordedAt: Date

    public init(
        id: UUID = UUID(),
        exerciseName: String,
        duration: Int,
        caloriesBurned: Int,
        recordedAt: Date
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.duration = duration
        self.caloriesBurned = caloriesBurned
        self.recordedAt = recordedAt
    }

    /// 시간 표시 문자열
    public var durationText: String {
        if duration >= 60 {
            let hours = duration / 60
            let mins = duration % 60
            if mins == 0 {
                return "\(hours)시간"
            }
            return "\(hours)시간 \(mins)분"
        }
        return "\(duration)분"
    }
}
