//
//  Color+SimpleCare.swift
//  BasePresentation
//
//  Created by JunHyeok Lee on 1/28/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import SwiftUI
import BaseDomain

// MARK: - SimpleCare Colors

public extension Color {

    // MARK: - Primary Colors

    /// 주 브랜드 색상 - 청록색 (Teal)
    /// Light: #00A6D4, Dark: #26B9E0
    static let scPrimary = Color("SCPrimary", bundle: .module)

    /// 보조 브랜드 색상 - 파랑 (Blue)
    /// Light: #2188F3, Dark: #429FF9
    static let scSecondary = Color("SCSecondary", bundle: .module)

    /// 강조 색상 - 보라 (Purple)
    /// Light: #62669B, Dark: #727EB4
    static let scAccent = Color("SCAccent", bundle: .module)

    // MARK: - Status Colors

    /// 성공/완료 상태 - 초록
    /// Light: #4CAF50, Dark: #66BB6A
    static let scSuccess = Color("SCSuccess", bundle: .module)

    /// 경고 상태 - 주황
    /// Light: #FF9800, Dark: #FFA72F
    static let scWarning = Color("SCWarning", bundle: .module)

    /// 에러/위험 상태 - 빨강
    /// Light: #EF5350, Dark: #F46360
    static let scError = Color("SCError", bundle: .module)

    // MARK: - Background Colors

    /// 메인 배경색
    /// Light: #F5F7FA, Dark: #1C1C1C
    static let scBackground = Color("SCBackground", bundle: .module)

    /// 카드/섹션 배경색
    /// Light: #FFFFFF, Dark: #2C2C2C
    static let scSurface = Color("SCSurface", bundle: .module)

    // MARK: - Text Colors

    /// 주요 텍스트 색상
    /// Light: #212121, Dark: #F5F5F5
    static let scTextPrimary = Color("SCTextPrimary", bundle: .module)

    /// 보조 텍스트 색상
    /// Light: #757575, Dark: #9E9E9E
    static let scTextSecondary = Color("SCTextSecondary", bundle: .module)

    // MARK: - Nutrition Colors

    /// 칼로리 표시 색상 - 빨강/주황
    /// Light: #FC5744, Dark: #FF6754
    static let scCalories = Color("SCCalories", bundle: .module)

    /// 단백질 표시 색상 - 분홍/보라
    /// Light: #9C51DD, Dark: #AB66E6
    static let scProtein = Color("SCProtein", bundle: .module)

    /// 탄수화물 표시 색상 - 주황
    /// Light: #FF9800, Dark: #FFA72F
    static let scCarbs = Color("SCCarbs", bundle: .module)

    /// 지방 표시 색상 - 연두
    /// Light: #8BCE26, Dark: #98D83D
    static let scFat = Color("SCFat", bundle: .module)

    // MARK: - Activity Colors

    /// 운동 표시 색상 - 청록/시안
    /// Light: #00D7FB, Dark: #33E0FF
    static let scExercise = Color("SCExercise", bundle: .module)

    // MARK: - BMI Helpers

    /// BMI 값에 따른 색상 반환
    static func bmiColor(for bmi: Double) -> Color {
        switch bmi {
        case ..<18.5: return .scWarning
        case 18.5..<25.0: return .scSuccess
        case 25.0..<30.0: return .scWarning
        default: return .scError
        }
    }

    /// BMI 값에 따른 카테고리 라벨 반환
    static func bmiCategoryLabel(for bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return "weight.bmi.underweight".localized
        case 18.5..<25.0: return "weight.bmi.normal".localized
        case 25.0..<30.0: return "weight.bmi.overweight".localized
        default: return "weight.bmi.obese".localized
        }
    }
}

// MARK: - ShapeStyle Extension

public extension ShapeStyle where Self == Color {

    // MARK: - Primary

    static var scPrimary: Color { .scPrimary }
    static var scSecondary: Color { .scSecondary }
    static var scAccent: Color { .scAccent }

    // MARK: - Status

    static var scSuccess: Color { .scSuccess }
    static var scWarning: Color { .scWarning }
    static var scError: Color { .scError }

    // MARK: - Background

    static var scBackground: Color { .scBackground }
    static var scSurface: Color { .scSurface }

    // MARK: - Text

    static var scTextPrimary: Color { .scTextPrimary }
    static var scTextSecondary: Color { .scTextSecondary }

    // MARK: - Nutrition

    static var scCalories: Color { .scCalories }
    static var scProtein: Color { .scProtein }
    static var scCarbs: Color { .scCarbs }
    static var scFat: Color { .scFat }

    // MARK: - Activity

    static var scExercise: Color { .scExercise }
}
