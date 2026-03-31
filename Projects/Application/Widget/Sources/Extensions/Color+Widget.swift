//
//  Color+Widget.swift
//  SimpleCareWidget
//
//  Widget 전용 시맨틱 색상 정의
//  BasePresentation의 Color+SimpleCare.swift와 동일한 값 사용
//

import SwiftUI

extension Color {

    // MARK: - Primary Colors

    /// 보조 브랜드 색상 - 파랑 (Blue)
    /// Light: #2188F3, Dark: #429FF9
    static let widgetSecondary = Color(red: 0x21/255, green: 0x88/255, blue: 0xF3/255)

    // MARK: - Status Colors

    /// 성공/완료 상태 - 초록
    /// Light: #4CAF50, Dark: #66BB6A
    static let widgetSuccess = Color(red: 0x4C/255, green: 0xAF/255, blue: 0x50/255)

    /// 경고 상태 - 주황
    /// Light: #FF9800, Dark: #FFA72F
    static let widgetWarning = Color(red: 0xFF/255, green: 0x98/255, blue: 0x00/255)
}
