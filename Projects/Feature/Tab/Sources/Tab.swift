//
//  Tab.swift
//  Features
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import Foundation

public enum AppTab: Hashable, CaseIterable {
    case home           // 홈 (메인)
    case meal           // 식단 기록
    case exercise       // 운동 기록
    case progress       // 진행 현황 (체중/목표)
    case settings       // 설정

    public var title: String {
        switch self {
        case .home: return "홈"
        case .meal: return "식단"
        case .exercise: return "운동"
        case .progress: return "진행"
        case .settings: return "설정"
        }
    }

    public var icon: String {
        switch self {
        case .home: return "house.fill"
        case .meal: return "fork.knife"
        case .exercise: return "figure.run"
        case .progress: return "chart.line.uptrend.xyaxis"
        case .settings: return "gearshape.fill"
        }
    }
}
