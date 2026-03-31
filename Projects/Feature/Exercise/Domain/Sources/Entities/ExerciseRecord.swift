//
//  ExerciseRecord.swift
//  ExerciseDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import BaseDomain

/// 운동 강도
public enum ExerciseIntensity: String, Codable, CaseIterable, Sendable {
    case light
    case moderate
    case vigorous

    public var displayName: String {
        switch self {
        case .light: return "exercise.intensity.light".localized
        case .moderate: return "exercise.intensity.moderate".localized
        case .vigorous: return "exercise.intensity.vigorous".localized
        }
    }
}

/// 운동 카테고리
public enum ExerciseCategory: String, Codable, CaseIterable, Sendable {
    case cardio
    case strength
    case flexibility
    case sports
    case other

    public var displayName: String {
        switch self {
        case .cardio: return "exercise.category.cardio".localized
        case .strength: return "exercise.category.strength".localized
        case .flexibility: return "exercise.category.flexibility".localized
        case .sports: return "exercise.category.sports".localized
        case .other: return "exercise.category.other".localized
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

/// 운동 종류
public enum ExerciseType: String, Codable, CaseIterable, Sendable {
    // 유산소
    case walking, running, cycling, swimming, hiking
    case stairClimbing, jumpRope, elliptical, rowing, dancing

    // 근력
    case weightLifting, bodyweightExercise, resistanceBands, pilates

    // 유연성
    case yoga, stretching

    // 스포츠
    case basketball, soccer, tennis, badminton, golf, tableTennis, volleyball

    // 기타
    case other

    public var displayName: String {
        switch self {
        case .walking: return "exercise.type.walking".localized
        case .running: return "exercise.type.running".localized
        case .cycling: return "exercise.type.cycling".localized
        case .swimming: return "exercise.type.swimming".localized
        case .hiking: return "exercise.type.hiking".localized
        case .stairClimbing: return "exercise.type.stairClimbing".localized
        case .jumpRope: return "exercise.type.jumpRope".localized
        case .elliptical: return "exercise.type.elliptical".localized
        case .rowing: return "exercise.type.rowing".localized
        case .dancing: return "exercise.type.dancing".localized
        case .weightLifting: return "exercise.type.weightLifting".localized
        case .bodyweightExercise: return "exercise.type.bodyweightExercise".localized
        case .resistanceBands: return "exercise.type.resistanceBands".localized
        case .pilates: return "exercise.type.pilates".localized
        case .yoga: return "exercise.type.yoga".localized
        case .stretching: return "exercise.type.stretching".localized
        case .basketball: return "exercise.type.basketball".localized
        case .soccer: return "exercise.type.soccer".localized
        case .tennis: return "exercise.type.tennis".localized
        case .badminton: return "exercise.type.badminton".localized
        case .golf: return "exercise.type.golf".localized
        case .tableTennis: return "exercise.type.tableTennis".localized
        case .volleyball: return "exercise.type.volleyball".localized
        case .other: return "exercise.type.other".localized
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

    /// 기본 MET 값
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

    public func adjustedMET(for intensity: ExerciseIntensity) -> Double {
        switch intensity {
        case .light: return baseMET * 0.75
        case .moderate: return baseMET
        case .vigorous: return baseMET * 1.3
        }
    }
}

/// 운동 기록 엔티티
public struct ExerciseRecord: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let userProfileId: UUID
    public var exerciseType: ExerciseType
    public var intensity: ExerciseIntensity
    public var durationMinutes: Int
    public var caloriesBurned: Int
    public var userWeightKg: Double
    public var date: Date
    public var notes: String?
    public var customExerciseName: String?
    public var customMET: Double?
    public let createdAt: Date
    public var updatedAt: Date

    /// 표시용 운동 이름 (커스텀이면 커스텀 이름, 아니면 exerciseType.displayName)
    public var displayName: String {
        if exerciseType == .other, let name = customExerciseName, !name.isEmpty {
            return name
        }
        return exerciseType.displayName
    }

    /// 실제 사용할 MET 값 (커스텀이면 customMET, 아니면 exerciseType.baseMET)
    public var effectiveBaseMET: Double {
        if exerciseType == .other, let met = customMET {
            return met
        }
        return exerciseType.baseMET
    }

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
        self.durationMinutes = max(1, durationMinutes)
        self.userWeightKg = max(0, userWeightKg)
        self.date = date
        self.notes = notes
        self.customExerciseName = customExerciseName
        self.customMET = customMET
        self.createdAt = createdAt
        self.updatedAt = updatedAt

        if let provided = caloriesBurned {
            self.caloriesBurned = provided
        } else {
            self.caloriesBurned = Self.calculateCalories(
                exerciseType: exerciseType,
                intensity: intensity,
                durationMinutes: durationMinutes,
                weightKg: userWeightKg,
                customMET: customMET
            )
        }
    }

    /// MET 기반 칼로리 계산
    public static func calculateCalories(
        exerciseType: ExerciseType,
        intensity: ExerciseIntensity,
        durationMinutes: Int,
        weightKg: Double,
        customMET: Double? = nil
    ) -> Int {
        guard durationMinutes > 0, weightKg > 0 else { return 0 }
        let baseMET = customMET ?? exerciseType.baseMET
        let intensityMultiplier: Double
        switch intensity {
        case .light: intensityMultiplier = 0.75
        case .moderate: intensityMultiplier = 1.0
        case .vigorous: intensityMultiplier = 1.3
        }
        let met = baseMET * intensityMultiplier
        let hours = Double(durationMinutes) / 60.0
        return Int(met * weightKg * hours)
    }

    public var durationDisplayString: String {
        let minUnit = "exercise.minutes".localized
        let hourUnit = "exercise.hours".localized
        if durationMinutes < 60 {
            return "\(durationMinutes)\(minUnit)"
        } else {
            let hours = durationMinutes / 60
            let mins = durationMinutes % 60
            if mins == 0 {
                return "\(hours)\(hourUnit)"
            } else {
                return "\(hours)\(hourUnit) \(mins)\(minUnit)"
            }
        }
    }
}
