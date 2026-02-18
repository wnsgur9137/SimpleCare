//
//  ExerciseRecordModel.swift
//  StorageInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import SwiftData

/// 운동 강도
public enum ExerciseIntensity: String, Codable, CaseIterable {
    case light = "light"       // 가벼운
    case moderate = "moderate" // 중간
    case vigorous = "vigorous" // 격렬한

    public var displayName: String {
        switch self {
        case .light: return "가벼운"
        case .moderate: return "보통"
        case .vigorous: return "격렬한"
        }
    }
}

/// 운동 카테고리
public enum ExerciseCategory: String, Codable, CaseIterable {
    case cardio = "cardio"         // 유산소
    case strength = "strength"     // 근력
    case flexibility = "flexibility" // 유연성
    case sports = "sports"         // 스포츠
    case other = "other"           // 기타

    public var displayName: String {
        switch self {
        case .cardio: return "유산소"
        case .strength: return "근력"
        case .flexibility: return "유연성"
        case .sports: return "스포츠"
        case .other: return "기타"
        }
    }

    public var icon: String {
        switch self {
        case .cardio: return "figure.run"
        case .strength: return "dumbbell.fill"
        case .flexibility: return "figure.yoga"
        case .sports: return "sportscourt.fill"
        case .other: return "figure.mixed.cardio"
        }
    }
}

/// 운동 종류와 MET 값
public enum ExerciseType: String, Codable, CaseIterable {
    // 유산소
    case walking = "walking"
    case running = "running"
    case cycling = "cycling"
    case swimming = "swimming"
    case hiking = "hiking"
    case stairClimbing = "stair_climbing"
    case jumpRope = "jump_rope"
    case elliptical = "elliptical"
    case rowing = "rowing"
    case dancing = "dancing"

    // 근력
    case weightLifting = "weight_lifting"
    case bodyweightExercise = "bodyweight_exercise"
    case resistanceBands = "resistance_bands"
    case pilates = "pilates"

    // 유연성
    case yoga = "yoga"
    case stretching = "stretching"

    // 스포츠
    case basketball = "basketball"
    case soccer = "soccer"
    case tennis = "tennis"
    case badminton = "badminton"
    case golf = "golf"
    case tableTennis = "table_tennis"
    case volleyball = "volleyball"

    // 기타
    case other = "other"

    public var displayName: String {
        switch self {
        case .walking: return "걷기"
        case .running: return "달리기"
        case .cycling: return "자전거"
        case .swimming: return "수영"
        case .hiking: return "등산"
        case .stairClimbing: return "계단 오르기"
        case .jumpRope: return "줄넘기"
        case .elliptical: return "일립티컬"
        case .rowing: return "로잉"
        case .dancing: return "춤"
        case .weightLifting: return "웨이트 트레이닝"
        case .bodyweightExercise: return "맨몸 운동"
        case .resistanceBands: return "밴드 운동"
        case .pilates: return "필라테스"
        case .yoga: return "요가"
        case .stretching: return "스트레칭"
        case .basketball: return "농구"
        case .soccer: return "축구"
        case .tennis: return "테니스"
        case .badminton: return "배드민턴"
        case .golf: return "골프"
        case .tableTennis: return "탁구"
        case .volleyball: return "배구"
        case .other: return "기타"
        }
    }

    public var category: ExerciseCategory {
        switch self {
        case .walking, .running, .cycling, .swimming, .hiking,
             .stairClimbing, .jumpRope, .elliptical, .rowing, .dancing:
            return .cardio
        case .weightLifting, .bodyweightExercise, .resistanceBands, .pilates:
            return .strength
        case .yoga, .stretching:
            return .flexibility
        case .basketball, .soccer, .tennis, .badminton, .golf, .tableTennis, .volleyball:
            return .sports
        case .other:
            return .other
        }
    }

    /// MET (Metabolic Equivalent of Task) 값
    /// 보통 강도 기준
    public var baseMET: Double {
        switch self {
        case .walking: return 3.5
        case .running: return 8.0
        case .cycling: return 6.0
        case .swimming: return 6.0
        case .hiking: return 5.3
        case .stairClimbing: return 8.0
        case .jumpRope: return 10.0
        case .elliptical: return 5.0
        case .rowing: return 7.0
        case .dancing: return 5.5
        case .weightLifting: return 5.0
        case .bodyweightExercise: return 3.8
        case .resistanceBands: return 3.5
        case .pilates: return 3.0
        case .yoga: return 2.5
        case .stretching: return 2.3
        case .basketball: return 6.5
        case .soccer: return 7.0
        case .tennis: return 7.3
        case .badminton: return 5.5
        case .golf: return 4.3
        case .tableTennis: return 4.0
        case .volleyball: return 4.0
        case .other: return 4.0
        }
    }

    /// 강도에 따른 MET 값 조정
    public func adjustedMET(for intensity: ExerciseIntensity) -> Double {
        switch intensity {
        case .light: return baseMET * 0.75
        case .moderate: return baseMET
        case .vigorous: return baseMET * 1.3
        }
    }
}

/// 운동 기록 모델
@Model
public final class ExerciseRecordModel {
    /// 고유 식별자
    @Attribute(.unique)
    public var id: UUID

    /// 사용자 프로필 ID
    public var userProfileId: UUID

    /// 운동 종류
    public var exerciseType: ExerciseType

    /// 운동 강도
    public var intensity: ExerciseIntensity

    /// 운동 시간 (분)
    public var durationMinutes: Int

    /// 소모 칼로리 (계산됨)
    public var caloriesBurned: Int

    /// 사용자 체중 (기록 시점, kg)
    public var userWeightKg: Double

    /// 기록 날짜/시간
    public var date: Date

    /// 메모
    public var notes: String?

    /// 커스텀 운동 이름 (exerciseType이 .other일 때)
    public var customExerciseName: String?

    /// 커스텀 MET 값 (exerciseType이 .other일 때)
    public var customMET: Double?

    /// 생성 일시
    public var createdAt: Date

    /// 수정 일시
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        userProfileId: UUID,
        exerciseType: ExerciseType,
        intensity: ExerciseIntensity = .moderate,
        durationMinutes: Int,
        caloriesBurned: Int? = nil,
        userWeightKg: Double,
        date: Date = Date(),
        notes: String? = nil,
        customExerciseName: String? = nil,
        customMET: Double? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userProfileId = userProfileId
        self.exerciseType = exerciseType
        self.intensity = intensity
        self.durationMinutes = durationMinutes
        self.userWeightKg = userWeightKg
        self.date = date
        self.notes = notes
        self.customExerciseName = customExerciseName
        self.customMET = customMET
        self.createdAt = createdAt
        self.updatedAt = updatedAt

        // 칼로리 계산
        if let provided = caloriesBurned {
            self.caloriesBurned = provided
        } else {
            self.caloriesBurned = Self.calculateCalories(
                exerciseType: exerciseType,
                intensity: intensity,
                durationMinutes: durationMinutes,
                weightKg: userWeightKg
            )
        }
    }

    /// MET 기반 칼로리 계산
    /// 칼로리 = MET x 체중(kg) x 시간(hour)
    public static func calculateCalories(
        exerciseType: ExerciseType,
        intensity: ExerciseIntensity,
        durationMinutes: Int,
        weightKg: Double
    ) -> Int {
        let met = exerciseType.adjustedMET(for: intensity)
        let hours = Double(durationMinutes) / 60.0
        return Int(met * weightKg * hours)
    }

    /// 시간 표시 문자열
    public var durationDisplayString: String {
        if durationMinutes < 60 {
            return "\(durationMinutes)분"
        } else {
            let hours = durationMinutes / 60
            let mins = durationMinutes % 60
            if mins == 0 {
                return "\(hours)시간"
            } else {
                return "\(hours)시간 \(mins)분"
            }
        }
    }
}
