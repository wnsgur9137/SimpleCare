//
//  Tab.swift
//  Features
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import Foundation
import BaseDomain

public enum AppTab: Hashable, CaseIterable {
    case home           // 홈 (메인)
    case meal           // 식단 기록
    case exercise       // 운동 기록
    case progress       // 진행 현황 (체중/목표)
    case calendar       // 캘린더

    public var title: String {
        switch self {
        case .home: return "tab.home".localized
        case .meal: return "tab.meal".localized
        case .exercise: return "tab.exercise".localized
        case .progress: return "tab.progress".localized
        case .calendar: return "tab.calendar".localized
        }
    }

    public var icon: String {
        switch self {
        case .home: return "house.fill"
        case .meal: return "fork.knife"
        case .exercise: return "figure.run"
        case .progress: return "chart.line.uptrend.xyaxis"
        case .calendar: return "calendar"
        }
    }
}
